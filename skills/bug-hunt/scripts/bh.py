"""bug-hunt output filters. Run from the repo root.
  python3 bh.py tests <dir>    one line per failed test: *.trx (VSTest/MTP), JUnit *.xml (vitest), Jest *.json
  python3 bh.py eslint <file>  one line per ESLint error from `eslint -f json`
Line format: name | message | file:line   (file:line = first stack frame inside the repo)
"""
import sys, os, glob, json, re
import xml.etree.ElementTree as ET

ROOT = os.getcwd().replace("\\", "/").rstrip("/")
NS = "{http://microsoft.com/schemas/VisualStudio/TeamTest/2010}"
BAD = {"Failed", "Error", "Timeout", "Aborted"}
ANSI = re.compile(r"\x1b\[[0-9;]*m")
NET_FRAME = re.compile(r" in (.+?):line (\d+)")
JS_FRAME = re.compile(r"((?:[A-Za-z]:)?[^\s()'\"]+\.(?:[cm]?[jt]sx?|vue)):(\d+)(?::\d+)?")


def one(s, n=160):
    return " ".join(ANSI.sub("", s or "").split())[:n]


def rel(p):
    p = (p or "").replace("\\", "/")
    if p.startswith("file://"):
        p = p[7:]
    return p[len(ROOT) + 1:] if p.startswith(ROOT + "/") else p


def frame(stack):
    cands = []
    for line in (stack or "").splitlines():
        m = NET_FRAME.search(line) or JS_FRAME.search(line.replace("file://", ""))
        if m:
            cands.append((m.group(1).replace("\\", "/"), m.group(2)))
    if not cands:
        return ""
    ours = [c for c in cands if "/_/" not in c[0] and "node_modules" not in c[0]]
    inrepo = [c for c in ours if c[0].startswith(ROOT + "/") or not os.path.isabs(c[0])]
    f, n = (inrepo or ours or cands)[0]
    return f"{rel(f)}:{n}"


def text(el, tag):
    x = el.find(f".//{NS}{tag}")
    return x.text if x is not None and x.text else ""


def trx(path):
    root = ET.parse(path).getroot()
    for u in root.iter(NS + "UnitTestResult"):
        o = u.get("outcome")
        if o in BAD:
            tag = "" if o == "Failed" else f"[{o}] "
            yield f"{u.get('testName')} | {tag}{one(text(u, 'Message'))} | {frame(text(u, 'StackTrace'))}"
    for ri in root.iter(NS + "RunInfo"):  # test-host crash, aborted run
        if ri.get("outcome") == "Error":
            yield f"RUN | {one(text(ri, 'Text'), 240)} |"


def junit(path):
    for tc in ET.parse(path).getroot().iter("testcase"):
        bad = tc.find("failure")
        if bad is None:
            bad = tc.find("error")
        if bad is None:
            continue
        name = " > ".join(x for x in (tc.get("classname"), tc.get("name")) if x)
        body = bad.text or ""
        yield f"{name} | {one(bad.get('message') or body)} | {frame(body) or rel(tc.get('file', ''))}"


def jest(path):
    with open(path, encoding="utf-8") as fh:
        d = json.load(fh)
    if not isinstance(d, dict) or "testResults" not in d:
        return
    for s in d["testResults"]:
        failed = [a for a in s.get("assertionResults", []) if a.get("status") == "failed"]
        for a in failed:
            msg = "\n".join(a.get("failureMessages") or [])
            head = re.split(r"\n\s+at ", msg, maxsplit=1)[0]
            yield f"{a.get('fullName') or a.get('title')} | {one(head)} | {frame(msg) or rel(s.get('name', ''))}"
        if not failed and s.get("status") == "failed":  # suite failed to run (import/syntax error)
            yield f"SUITE {rel(s.get('name', ''))} | {one(s.get('message', ''), 240)} |"


def tests(d):
    for p in sorted(glob.glob(os.path.join(d, "**", "*"), recursive=True)):
        try:
            if p.endswith(".trx"):
                yield from trx(p)
            elif p.endswith(".xml"):
                yield from junit(p)
            elif p.endswith(".json"):
                yield from jest(p)
        except (ET.ParseError, ValueError, OSError) as e:
            yield f"PARSE {rel(p)} | {one(str(e))} |"


def eslint(path):
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
    for r in data:
        for m in r.get("messages", []):
            if m.get("severity") == 2:
                yield f"{rel(r.get('filePath'))}:{m.get('line', 0)} | {m.get('ruleId') or 'parse'} | {one(m.get('message'), 140)}"


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("tests", "eslint"):
        sys.exit(__doc__)
    for line in (tests if sys.argv[1] == "tests" else eslint)(sys.argv[2]):
        print(line)
