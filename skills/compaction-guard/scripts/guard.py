#!/usr/bin/env python3
"""guard.py — keep the important context across Claude Code compaction.

  guard.py install [--user] [--on-clear]   add the hooks to settings.json (idempotent, backs it up)
  guard.py uninstall [--user]              remove them
  guard.py precompact                      PreCompact hook: snapshot the session, steer the summary
  guard.py sessionstart                    SessionStart hook: re-inject NOW.md + snapshot after compaction
  guard.py status                          show what would be re-injected

State lives in <project>/.claude/compaction-guard/:
  NOW.md        the living state file Claude keeps current (goal, decisions, next steps)
  snapshot.md   written automatically before each compaction from the transcript
Python 3 standard library only. Hook modes never fail the session: on any error they exit 0.
"""
import json
import os
import re
import shutil
import sys
import time
from collections import OrderedDict

NOW_MAX = 6000          # SessionStart output is truncated by Claude Code past ~10k chars
SNAP_MAX = 3000
PRECOMPACT_MAX = 1500   # PreCompact stdout is appended to the compaction instructions
REMINDER = re.compile(r"<system-reminder>.*?</system-reminder>", re.S)
TAGS = re.compile(r"</?(command-name|command-message|command-args|local-command-stdout)[^>]*>")
SECRET = re.compile(r"(?i)\b(password|passwd|secret|api[_-]?key|token|bearer)(\s*[=:]?\s*)\S{6,}")


def project_dir(data=None):
    return os.environ.get("CLAUDE_PROJECT_DIR") or (data or {}).get("cwd") or os.getcwd()


def state_dir(data=None):
    return os.path.join(project_dir(data), ".claude", "compaction-guard")


def read_hook_input():
    try:
        return json.load(sys.stdin)
    except (ValueError, OSError):
        return {}


def clip(s, n):
    return s if len(s) <= n else s[: n - 40] + f"\n… [{len(s) - n + 40} chars cut]"


# ------------------------------------------------------------ transcript → snapshot
def user_text(msg):
    c = msg.get("content") if isinstance(msg, dict) else None
    if isinstance(c, str):
        parts = [c]
    elif isinstance(c, list):
        parts = [b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"]
    else:
        parts = []
    return TAGS.sub("", REMINDER.sub("", "\n".join(parts))).strip()


def snapshot_from_transcript(path):
    prompts, files, errors, notes = [], OrderedDict(), [], []
    pending = {}
    try:
        fh = open(path, encoding="utf-8", errors="replace")
    except (OSError, TypeError):
        return None
    with fh:
        for line in fh:
            try:
                o = json.loads(line)
            except ValueError:
                continue
            if not isinstance(o, dict) or o.get("isSidechain") or o.get("isMeta"):
                continue
            msg = o.get("message")
            content = msg.get("content") if isinstance(msg, dict) else None
            if o.get("type") == "user":
                t = user_text(msg)
                if t and not t.startswith("[Request interrupted"):
                    prompts.append(t)
                if isinstance(content, list):
                    for b in content:
                        if isinstance(b, dict) and b.get("type") == "tool_result" and b.get("is_error"):
                            c = b.get("content")
                            if isinstance(c, list):
                                c = " ".join(x.get("text", "") for x in c if isinstance(x, dict))
                            first = " | ".join([x.strip() for x in str(c).splitlines() if x.strip()][:2])
                            errors.append(f"{pending.get(b.get('tool_use_id'), '?')}: {first[:160]}")
            elif o.get("type") == "assistant" and isinstance(content, list):
                for b in content:
                    if not isinstance(b, dict):
                        continue
                    if b.get("type") == "tool_use":
                        inp = b.get("input") or {}
                        name = b.get("name", "?")
                        fp = inp.get("file_path") if isinstance(inp, dict) else None
                        if name in ("Write", "Edit", "MultiEdit", "NotebookEdit") and fp:
                            files.pop(fp, None)
                            files[fp] = name
                        desc = f"{name} {fp or str(inp.get('command', ''))[:60] if isinstance(inp, dict) else ''}".strip()
                        pending[b.get("id")] = desc
                    elif b.get("type") == "text" and b.get("text", "").strip():
                        notes.append(b["text"].strip().splitlines()[0][:200])

    root = project_dir().rstrip("/") + "/"
    rel = lambda p: p[len(root):] if p.startswith(root) else p
    out = ["# Auto snapshot before compaction",
           f"_written {time.strftime('%Y-%m-%d %H:%M:%S %Z')} from the transcript — facts, not a plan_", ""]
    if prompts:
        out.append("## First request in this session")
        out.append(SECRET.sub(r"\1\2<redacted>", clip(prompts[0], 500)))
        out.append("")
        out.append("## Most recent user messages (oldest first)")
        for p in prompts[-5:]:
            out.append("- " + SECRET.sub(r"\1\2<redacted>", clip(p.replace("\n", " "), 400)))
        out.append("")
    if files:
        out.append("## Files changed (most recent last)")
        out.append(", ".join(rel(f) for f in list(files)[-20:]))
        out.append("")
    if errors:
        out.append("## Recent tool failures")
        out += ["- " + SECRET.sub(r"\1\2<redacted>", e) for e in errors[-4:]]
        out.append("")
    if notes:
        out.append("## Last assistant notes")
        out += [f"- {n}" for n in notes[-3:]]
    return "\n".join(out)


# ------------------------------------------------------------ hooks
def cmd_precompact():
    data = read_hook_input()
    d = state_dir(data)
    try:
        os.makedirs(d, exist_ok=True)
        snap = snapshot_from_transcript(data.get("transcript_path"))
        if snap:
            with open(os.path.join(d, "snapshot.md"), "w", encoding="utf-8") as fh:
                fh.write(snap)
    except Exception:              # never block compaction
        pass
    now = os.path.join(d, "NOW.md")
    has_now = os.path.isfile(now)
    msg = ("Compaction guard: in the summary, keep verbatim the user's current goal, every explicit user "
           "instruction or constraint, decisions with their reasons, exact file paths and identifiers being "
           "worked on, unresolved errors, and the next concrete step. Drop tool output and dead ends. ")
    msg += ("The state file .claude/compaction-guard/NOW.md and an automatic snapshot will be re-injected after "
            "compaction, so the summary may refer to them." if has_now else
            "An automatic snapshot will be re-injected after compaction.")
    print(clip(msg, PRECOMPACT_MAX))
    return 0


def build_context(d):
    parts = []
    now = os.path.join(d, "NOW.md")
    snap = os.path.join(d, "snapshot.md")
    if os.path.isfile(now):
        with open(now, encoding="utf-8", errors="replace") as fh:
            age = int((time.time() - os.path.getmtime(now)) / 60)
            parts.append(f"## .claude/compaction-guard/NOW.md (your state file, updated {age} min ago)\n"
                         + clip(fh.read().strip(), NOW_MAX))
    if os.path.isfile(snap):
        with open(snap, encoding="utf-8", errors="replace") as fh:
            parts.append(clip(fh.read().strip(), SNAP_MAX))
    if not parts:
        return ""
    head = ("[compaction-guard] Context was just compacted. Re-read this before continuing. If NOW.md is older "
            "than the latest snapshot's user messages, update NOW.md first.\n\n")
    return head + "\n\n".join(parts)


def cmd_sessionstart():
    data = read_hook_input()
    try:
        ctx = build_context(state_dir(data))
    except Exception:
        return 0
    if ctx:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ctx}},
                         ensure_ascii=False))
    return 0


def cmd_status():
    d = state_dir()
    ctx = build_context(d)
    print(f"state dir: {d}")
    print(ctx if ctx else "nothing to re-inject (no NOW.md or snapshot.md yet)")
    print(f"\n[{len(ctx)} chars; Claude Code truncates SessionStart context past ~10000]")
    return 0


# ------------------------------------------------------------ install
MARK = "compaction-guard/guard.py"


def settings_path(user):
    return (os.path.join(os.path.expanduser("~"), ".claude", "settings.json") if user
            else os.path.join(project_dir(), ".claude", "settings.json"))


def load_settings(p):
    if not os.path.isfile(p):
        return {}
    with open(p, encoding="utf-8") as fh:
        txt = fh.read().strip()
    return json.loads(txt) if txt else {}


def strip_ours(groups):
    out = []
    for g in groups or []:
        hooks = [h for h in g.get("hooks", []) if MARK not in str(h.get("command", ""))]
        if hooks:
            out.append({**g, "hooks": hooks})
    return out


def cmd_install(argv, remove=False):
    user = "--user" in argv
    p = settings_path(user)
    try:
        s = load_settings(p)
    except ValueError as e:
        print(f"{p} is not valid JSON ({e}); fix it first. Nothing changed.")
        return 1
    if os.path.isfile(p):
        shutil.copy2(p, p + ".bak")
    hooks = s.setdefault("hooks", {})
    for ev in ("PreCompact", "SessionStart"):
        hooks[ev] = strip_ours(hooks.get(ev))
    if not remove:
        if user:
            dest_dir = os.path.join(os.path.expanduser("~"), ".claude", "compaction-guard")
            cmd = f'python3 "{os.path.join(dest_dir, "guard.py")}"'
        else:
            dest_dir = os.path.join(project_dir(), ".claude", "compaction-guard")
            cmd = 'python3 "$CLAUDE_PROJECT_DIR/.claude/compaction-guard/guard.py"'
        os.makedirs(dest_dir, exist_ok=True)
        if os.path.abspath(__file__) != os.path.abspath(os.path.join(dest_dir, "guard.py")):
            shutil.copy2(os.path.abspath(__file__), os.path.join(dest_dir, "guard.py"))
        hooks["PreCompact"].append({"matcher": "", "hooks": [{"type": "command", "command": f"{cmd} precompact"}]})
        for m in ["compact"] + (["clear"] if "--on-clear" in argv else []):
            hooks["SessionStart"].append({"matcher": m, "hooks": [{"type": "command", "command": f"{cmd} sessionstart"}]})
    for ev in ("PreCompact", "SessionStart"):
        if not hooks[ev]:
            del hooks[ev]
    if not hooks:
        del s["hooks"]
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fh:
        json.dump(s, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"{'removed from' if remove else 'installed in'} {p}" + (f" (backup: {p}.bak)" if os.path.isfile(p + '.bak') else ""))
    if not remove:
        print("Hooks load at session start: restart Claude Code (or open /hooks) for them to take effect.")
    return 0


def main(argv):
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__.strip())
        return 2
    c = argv[0]
    if c == "precompact":
        return cmd_precompact()
    if c == "sessionstart":
        return cmd_sessionstart()
    if c == "status":
        return cmd_status()
    if c == "install":
        return cmd_install(argv[1:])
    if c == "uninstall":
        return cmd_install(argv[1:], remove=True)
    print(f"unknown command {c}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:                            # hook safety net
        if len(sys.argv) > 1 and sys.argv[1] in ("precompact", "sessionstart"):
            sys.exit(0)
        raise
