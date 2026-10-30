#!/usr/bin/env python3
"""rtl_lint.py — find RTL problems in a front end (Python 3 standard library only).

Usage: python3 rtl_lint.py <path> [<path> ...] [--max N] [--summary]

Prints `exit=<0|1> findings=<n> files=<n>` first, then one line per finding:
    file:line  RULE  snippet  → suggestion
Exit code 1 when anything was found. Add `rtl-ok` in a comment on a line to silence it.
"""
import os
import re
import sys
from collections import Counter

SKIP_DIRS = {"node_modules", ".git", "dist", "build", "out", "bin", "obj", ".next", ".nuxt",
             "coverage", "vendor", ".angular", ".svelte-kit", "Migrations"}
CSS_EXT = {".css", ".scss", ".sass", ".less"}
MARKUP_EXT = {".html", ".htm", ".jsx", ".tsx", ".vue", ".svelte", ".cshtml", ".razor", ".astro"}
SCRIPT_EXT = {".js", ".ts", ".mjs", ".cjs"}
CS_EXT = {".cs"}
ALL_EXT = CSS_EXT | MARKUP_EXT | SCRIPT_EXT | CS_EXT

# --- CSS (in stylesheets and <style>/inline style text) ---
CSS_RULES = [
    (re.compile(r"(?<![\w-])(margin|padding|border|scroll-margin|scroll-padding)-(left|right)(?=[\s:-])"),
     "css-physical", lambda m: f"{m.group(1)}-inline-{'start' if m.group(2) == 'left' else 'end'}"),
    (re.compile(r"(?<![\w-])border-(top|bottom)-(left|right)-radius"),
     "css-radius", lambda m: f"border-{'start' if m.group(1) == 'top' else 'end'}-{'start' if m.group(2) == 'left' else 'end'}-radius"),
    (re.compile(r"(?<![\w-])text-align\s*:\s*(left|right)\b"),
     "css-text-align", lambda m: f"text-align: {'start' if m.group(1) == 'left' else 'end'}"),
    (re.compile(r"(?<![\w-])(float|clear)\s*:\s*(left|right)\b"),
     "css-float", lambda m: f"{m.group(1)}: inline-{'start' if m.group(2) == 'left' else 'end'}"),
    (re.compile(r"(?<![\w-])(left|right)\s*:\s*(?!auto\b)[-\d.]"),
     "css-inset", lambda m: f"inset-inline-{'start' if m.group(1) == 'left' else 'end'}"),
    (re.compile(r"flex-direction\s*:\s*row-reverse"),
     "row-reverse", lambda m: "dir=rtl already reverses rows; remove unless intentional"),
]

# --- JS/TS style objects ---
JS_RULES = [
    (re.compile(r"\b(margin|padding|border)(Left|Right)\s*:"),
     "js-physical", lambda m: f"{m.group(1)}Inline{'Start' if m.group(2) == 'Left' else 'End'}"),
    (re.compile(r"\btextAlign\s*:\s*['\"](left|right)['\"]"),
     "js-text-align", lambda m: f"textAlign: '{'start' if m.group(1) == 'left' else 'end'}'"),
    (re.compile(r"flexDirection\s*:\s*['\"]row-reverse['\"]"),
     "row-reverse", lambda m: "dir=rtl already reverses rows; remove unless intentional"),
]

# --- Tailwind classes (only inside markup files) ---
TW_MAP = {"ml": "ms", "mr": "me", "pl": "ps", "pr": "pe", "left": "start", "right": "end",
          "rounded-l": "rounded-s", "rounded-r": "rounded-e", "rounded-tl": "rounded-ss",
          "rounded-tr": "rounded-se", "rounded-bl": "rounded-es", "rounded-br": "rounded-ee",
          "border-l": "border-s", "border-r": "border-e", "scroll-ml": "scroll-ms",
          "scroll-mr": "scroll-me", "scroll-pl": "scroll-ps", "scroll-pr": "scroll-pe"}
TW_RE = re.compile(
    r"(?<=[\s\"'`{:])(?P<neg>-)?(?P<base>rounded-(?:tl|tr|bl|br|l|r)|border-(?:l|r)|scroll-(?:m|p)(?:l|r)|ml|mr|pl|pr|left|right)"
    r"(?P<rest>(?:-[\w./%\[\]-]+)?)(?=[\s\"'`}]|$)")
TW_SIMPLE = re.compile(r"(?<=[\s\"'`{:])(text-left|text-right|float-left|float-right|flex-row-reverse)(?=[\s\"'`}]|$)")
TW_SIMPLE_FIX = {"text-left": "text-start", "text-right": "text-end", "float-left": "float-start",
                 "float-right": "float-end", "flex-row-reverse": "remove (dir=rtl already reverses)"}

# --- Arabic letters in Persian source text ---
ARABIC_CHARS = re.compile("[يك]")
CLASS_CONTEXT = re.compile(r"class(Name)?\s*=|clsx\(|cn\(|cva\(|tw`|@apply")


def iter_files(paths):
    for root in paths:
        if os.path.isfile(root):
            yield root
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for f in filenames:
                ext = os.path.splitext(f)[1].lower()
                if ext in ALL_EXT and ".min." not in f:
                    yield os.path.join(dirpath, f)


def lint_line(line, ext, in_style):
    out = []
    if "rtl-ok" in line:
        return out
    stripped = line.lstrip()
    is_comment = stripped.startswith(("//", "/*", "*", "<!--", "@*"))
    css_like = ext in CSS_EXT or in_style or "style=" in line
    if css_like and not is_comment:
        for rx, rule, fix in CSS_RULES:
            for m in rx.finditer(line):
                out.append((rule, m.group(0), fix(m)))
    if ext in MARKUP_EXT | SCRIPT_EXT and not is_comment:
        for rx, rule, fix in JS_RULES:
            for m in rx.finditer(line):
                out.append((rule, m.group(0), fix(m)))
    if (ext in MARKUP_EXT or (ext in CSS_EXT and "@apply" in line) or CLASS_CONTEXT.search(line)) and not is_comment:
        for m in TW_RE.finditer(line):
            # skip deliberate direction variants: rtl:ml-2 / ltr:ml-2
            prefix = line[max(0, m.start() - 4):m.start()]
            if prefix.endswith(("rtl:", "ltr:")):
                continue
            base = m.group("base")
            rest = m.group("rest")
            if base in ("left", "right") and not rest:
                continue  # plain words "left"/"right" in text
            out.append(("tw-physical", m.group(0), f"{m.group('neg') or ''}{TW_MAP[base]}{rest}"))
        for m in TW_SIMPLE.finditer(line):
            prefix = line[max(0, m.start() - 4):m.start()]
            if prefix.endswith(("rtl:", "ltr:")):
                continue
            out.append(("tw-physical" if m.group(1) != "flex-row-reverse" else "row-reverse",
                        m.group(1), TW_SIMPLE_FIX[m.group(1)]))
    if ARABIC_CHARS.search(line):
        out.append(("arabic-char", ARABIC_CHARS.search(line).group(0),
                    "use Persian ی (U+06CC) / ک (U+06A9), or normalize; rtl-ok if the text is Arabic"))
    return out


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    max_n = 200
    if "--max" in argv:
        i = argv.index("--max")
        try:
            max_n = int(argv[i + 1])
            args = [a for a in args if a != argv[i + 1]]
        except (IndexError, ValueError):
            print("--max needs a number", file=sys.stderr)
            return 2
    if not args:
        print(__doc__.strip())
        return 2

    findings, files = [], 0
    for path in iter_files(args):
        files += 1
        ext = os.path.splitext(path)[1].lower()
        try:
            with open(path, encoding="utf-8", errors="replace") as fh:
                in_style = False
                for no, line in enumerate(fh, 1):
                    low = line.lower()
                    if "<style" in low:
                        in_style = True
                    for rule, snip, fix in lint_line(line, ext, in_style):
                        findings.append((path, no, rule, snip.strip(), fix))
                    if "</style" in low:
                        in_style = False
        except OSError as e:
            print(f"warn: cannot read {path}: {e}", file=sys.stderr)

    code = 1 if findings else 0
    print(f"exit={code} findings={len(findings)} files={files}")
    if findings:
        by_rule = Counter(f[2] for f in findings)
        print("by rule: " + ", ".join(f"{r}={n}" for r, n in by_rule.most_common()))
    if "--summary" not in argv:
        for path, no, rule, snip, fix in findings[:max_n]:
            print(f"{path}:{no}  {rule}  {snip}  → {fix}")
        if len(findings) > max_n:
            print(f"... {len(findings) - max_n} more (use --max N or fix by rule)")
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
