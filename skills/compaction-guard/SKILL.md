---
name: compaction-guard
description: Keep goals, user instructions, decisions and next steps alive across Claude Code context compaction (auto-compact or /compact) and long sessions. Use when a session is long or will be, when the user complains that Claude forgot instructions or lost the thread after compacting, when starting a big multi-step task, or to install the PreCompact/SessionStart hooks that snapshot and re-inject state.
---

# Compaction guard

Compaction summarizes the conversation and throws away the rest. What gets lost is predictable: the user's exact instructions, why decisions were made, which files were mid-change, and what was next. This skill keeps that in a small **state file** and re-injects it automatically after every compaction.

Three layers, cheapest first:
1. **`NOW.md`** — a living state file you keep current (the part that actually matters).
2. **PreCompact hook** — writes an automatic snapshot from the transcript and tells the compactor what to keep.
3. **SessionStart(compact) hook** — puts `NOW.md` + the snapshot back into context right after compaction.

## Install the hooks (once per project, or `--user` for all projects)
`python3 <skill-dir>/scripts/guard.py install` — copies `guard.py` to `.claude/compaction-guard/`, merges the hooks into `.claude/settings.json` (keeps existing hooks, writes a `.bak`), and is safe to run twice. `--on-clear` also re-injects after `/clear`; `uninstall` removes only its own hooks. Hooks load at session start: tell the user to restart Claude Code (or check with `/hooks`). Add `.claude/compaction-guard/` to `.gitignore` unless the team wants to share it.

`guard.py status` shows exactly what would be re-injected and its size.

## NOW.md — the state file
Path: `.claude/compaction-guard/NOW.md`. Current state, not a log. ≤60 lines (re-injection is capped at ~6,000 chars; Claude Code cuts SessionStart context past ~10,000).
```markdown
# NOW — <task in a few words>
Goal: <what the user wants, in their words>
Constraints (user's explicit instructions — verbatim):
- <"don't touch the public API">
- <"answer me in Persian, code in English">
Decisions:
- <decision> — because <reason>
Done: <short list>
In progress: <file:area — what's half-changed>
Next: <the very next concrete step>, then <…>
Open questions / blocked on: <…>
```
**Update it** (Edit, a few lines — never rewrite from memory):
- when the user gives an instruction, preference or correction that should outlive this turn;
- after a decision, after finishing a step, before starting a long command or a subagent batch;
- when the conversation is getting long (many large tool results) — compaction is near.
Don't put tool output, code, or secrets in it.

## After compaction
When context starts with `[compaction-guard] Context was just compacted`:
1. Read the injected NOW.md and snapshot before doing anything else.
2. If the snapshot's latest user messages contain something NOW.md doesn't (a new instruction, a changed goal), update NOW.md first.
3. If anything is ambiguous (a half-done edit, an unclear next step), re-check the file or `git diff` — don't guess from the summary.
4. Continue from **Next**. Tell the user one line only if something was unclear and you had to re-check.

## Without hooks
If the user doesn't want hooks: still keep NOW.md, and after a compaction (the conversation starts with a summary) read it yourself first. For a manual `/compact`, suggest instructions such as `/compact keep the constraints and next steps from NOW.md`.

## Hook behaviour (for debugging)
- `precompact`: reads `transcript_path` from the hook input, writes `snapshot.md` (first request, last 5 user messages, files changed, recent tool failures, last assistant notes — secrets redacted), prints ≤1,500 chars of instructions that Claude Code appends to the compaction prompt. Never exits 2 (that would block compaction); any error → exit 0.
- `sessionstart`: prints `hookSpecificOutput.additionalContext` with NOW.md (≤6,000 chars) + snapshot (≤3,000).

## When NOT to use
Short sessions, one-off questions, or when the user prefers `/clear` and a fresh start (then NOW.md is still a good handoff note).
