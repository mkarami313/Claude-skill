# Claude Skills

A collection of [Claude skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) for real-world development work, packaged as a Claude Code plugin marketplace.

| Skill | What it does |
|---|---|
| [bug-hunt](skills/bug-hunt/SKILL.md) | Token-efficient bug hunting in large .NET + React web apps (200k+ lines, modular monolith, multi-tenant). |
| [task-observer](skills/task-observer/SKILL.md) | Watch long-running commands without reading their logs (stalled / repeating / done) and catch agent loops with a PostToolUse hook. |
| [record-skill](skills/record-skill/SKILL.md) | Record a workflow and turn the real session transcript — steps, fixes and your corrections — into a reusable skill. |
| [compaction-guard](skills/compaction-guard/SKILL.md) | Keep goals, instructions, decisions and next steps across context compaction: NOW.md state file + PreCompact/SessionStart hooks. |
| [framework-upgrade](skills/framework-upgrade/SKILL.md) | Evidence-driven framework/runtime upgrades: official guides first, baseline, codemods, one green step at a time, no silenced errors. |
| [iran-payments](skills/iran-payments/SKILL.md) | Iranian payment gateways (ZarinPal, Zibal, any PSP): safe callback → verify flow, Rial/Toman, idempotency, reconciliation, review checklist, C#/.NET reference. |
| [persian-rtl](skills/persian-rtl/SKILL.md) | Persian RTL web UIs: logical CSS/Tailwind, mirroring, bidi, ی/ک and digit normalization, ZWNJ, Jalali dates, fonts — with an RTL lint script. |

The general-purpose skills are also published as standalone repos (same content, installable on their own):

| Skill | Standalone repo |
|---|---|
| `task-observer` | [mkarami313/claude-task-observer](https://github.com/mkarami313/claude-task-observer) |
| `record-skill` | [mkarami313/claude-record-skill](https://github.com/mkarami313/claude-record-skill) |
| `compaction-guard` | [mkarami313/claude-compaction-guard](https://github.com/mkarami313/claude-compaction-guard) |
| `framework-upgrade` | [mkarami313/claude-framework-upgrade](https://github.com/mkarami313/claude-framework-upgrade) |

## Installation

### Claude Code — plugin marketplace (recommended)
```
/plugin marketplace add mkarami313/Claude-skill
/plugin install bug-hunt@mkarami313-skills
/plugin install task-observer@mkarami313-skills
/plugin install record-skill@mkarami313-skills
/plugin install compaction-guard@mkarami313-skills
/plugin install framework-upgrade@mkarami313-skills
/plugin install iran-payments@mkarami313-skills
/plugin install persian-rtl@mkarami313-skills
```
Update later with `/plugin marketplace update mkarami313-skills`.

### Claude Code — copy into a project or your user folder
```bash
git clone https://github.com/mkarami313/Claude-skill
cp -r Claude-skill/skills/<skill> <your-repo>/.claude/skills/     # this project only
cp -r Claude-skill/skills/<skill> ~/.claude/skills/               # all your projects
```

### Claude.ai / Claude desktop app
Zip the skill folder so that `bug-hunt/SKILL.md` is at the root of the archive, then upload it in Claude's skills settings (if only `SKILL.md` is uploaded, the skill fetches its scripts and references from this repo on first use):
```bash
cd Claude-skill/skills && zip -r bug-hunt.zip bug-hunt
```

---

## bug-hunt

Debugging a 200k+ line codebase burns tokens in four ways: reading too much code, reading raw logs, cold-starting agents for small jobs, and keeping one session alive too long. `bug-hunt` prevents all four. A **ledger** on disk is the memory, so each session stays small and the next one resumes where the last one stopped.

**Use it when** you want to find, triage or fix bugs, build/type/lint errors or failing tests in the C#/.NET backend or the React/TypeScript frontend — or to resume a bug-fixing session. In Claude Code, run `/bug-hunt` or just ask ("find the failing tests in Ordering and fix them").

### How it works
| Phase | What happens |
|---|---|
| 0. Setup (once per repo) | Copies the scripts to `.bughunt/` (kept out of git through `.git/info/exclude`), adds an `.ignore` so searches skip migrations and generated code, and writes a short `map.md` of the repo. |
| 1. Triage | Builds and tests the backend and frontend once; every problem becomes one line in `.bughunt/ledger.md`, with severity S0–S3. Error clusters with one root cause count as one bug. |
| 2. Plan | Groups bugs by module and root cause; one group per session; marks which groups need a stronger model. |
| 3. Fix loop | Per bug: locate → failing test (seen failing for the right reason) → root cause with evidence → minimal fix → verify with a fresh run → ledger row → commit on a `bughunt/<group>` branch. Two wrong hypotheses → a short dossier goes to an Opus subagent; three failed fixes → stop and ask the user (likely a design problem). |
| 4. Review | An independent reviewer subagent reads only a diff file: per bug for S0/money/tenant/auth/migration fixes, and once per group. |

### What's inside
```
skills/bug-hunt/
├── SKILL.md                      workflow, rules, ledger format
├── scripts/
│   ├── build.sh                  dotnet build → error list clustered by code and module
│   ├── test-dotnet.sh            dotnet test (VSTest or Microsoft.Testing.Platform) → one line per failure
│   ├── web-triage.sh             tsc + ESLint + vitest/jest → one line per problem
│   ├── polluter.sh               bisection: which test pollutes a flaky one (.NET classes or web test files)
│   ├── review-pkg.sh             commits + stat + diff in one file for the reviewer
│   └── bh.py                     parser for TRX, JUnit XML, Jest JSON and ESLint JSON
└── references/                   loaded only when needed
    ├── root-cause.md             tracing, boundary probes, hypotheses, escalation ladder, flaky tests
    ├── review.md                 when to review, reviewer brief, acting on findings
    ├── checklist-dotnet.md       tenant isolation, DI lifetimes, async, EF Core, money, time, security
    ├── checklist-react.md        effects, data-fetching races, cache keys, state, auth, RTL
    └── checklist-contract.md     API ↔ React contract, Persian text, Iranian payment gateways
```

### Design choices that save tokens
- **Exit codes first.** Every script prints `exit=…` before anything else, and warns when a run failed but nothing was parsed (crash, abort, wrong tsconfig) — an empty error list is never mistaken for green.
- **Logs go to files**, never into the conversation; only summaries and one-line rows are printed.
- **Grep before Read**, and Read only 40–120 line ranges; generated files are hidden by `.ignore`.
- **Subagents only for reading volume** (>~400 lines). Haiku for triage and maps, Opus for hard root causes; the session itself writes the fixes.
- **Checklists load on demand**, so `SKILL.md` stays small.
- **Evidence before guesses.** Each hypothesis is written down and tested with one change; a wrong fix costs a build, a test run and a revert, so guessing is the most expensive habit.
- **Explicit model on every subagent.** Haiku only for one-shot reading; anything multi-step (map, tracing, review) starts at Sonnet, because cheap models take 2–3× the turns.
- **Reviews read a diff file**, never the conversation, and only where the risk pays for them.
- **Parallel groups** run in separate git worktrees, so builds and the ledger never collide.

### Requirements
- .NET SDK (tested layout: .NET 8–10; xUnit, NUnit or MSTest)
- Node.js with npm, pnpm or yarn for the frontend
- `bash` (Git Bash or WSL on Windows) and Python 3

### Notes
- With Microsoft.Testing.Platform, the single-test filter defaults to xUnit v3's `--filter-method`; set `BH_MTP_FILTER=vstest` for MSTest/NUnit.
- If the frontend type-checks a different tsconfig, run `TSCONFIG=<file> bash .bughunt/web-triage.sh <web-dir>`.

### Credits
The evidence-first debugging rules, the review gate and the test-pollution bisection are adapted from [obra/superpowers](https://github.com/obra/superpowers) (MIT, © Jesse Vincent) — `systematic-debugging`, `verification-before-completion` and `subagent-driven-development`.

---

## task-observer

Long-running work fails in two ways: Claude **polls blind** (re-reads huge logs, sleeps in loops, or forgets the job exists) or **goes in circles** (re-runs the same failing command, re-edits the same file). `task-observer` fixes both with two small, dependency-free scripts.

**Use it when** a command may take more than a minute or two (builds, test suites, migrations, data jobs, training, deploys), when several jobs run in parallel, when you ask Claude to "keep an eye on" something — or to install the loop guard for long autonomous runs.

### How it works
| Piece | What it does |
|---|---|
| `observe.py run <name> -- <cmd>` | Runs the command in the background, logs to `.observer/<name>.log`, keeps `.observer/<name>.json` current: state, elapsed, idle time, last progress line (`37%`, `120/500`, `epoch 4`), most-repeated error (numbers and paths normalized). |
| `observe.py wait <name>` | Blocks until something happens and prints one status block. Exit `0` done · `1` failed · `3` **stalled** (no output for `--stall` s) or **repeating** (same error `--repeat` times) · `4` timeout. Run it in the background and Claude is woken up only when it matters. |
| `observe.py status [name]` | One line per task, or details for one. |
| `loop_guard.py` (PostToolUse hook) | Warns Claude when, in the last 30 tool calls, the same call repeats 3×, the same call fails 3×, 5 calls fail in a row, or one file is edited 6×. Warnings go to Claude (exit 2) at most once per 10 calls; it never blocks a call. |

### Loop guard setup
Copy `skills/task-observer/scripts/loop_guard.py` to `.observer/` in your project and add to `.claude/settings.json`:
```json
{ "hooks": { "PostToolUse": [ { "matcher": "*", "hooks": [
  { "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR/.observer/loop_guard.py\"" } ] } ] } }
```
Tune with `LOOP_GUARD_WINDOW`, `_SAME`, `_FAIL`, `_FAIL_STREAK`, `_EDITS`, `_COOLDOWN`; disable with `LOOP_GUARD_OFF=1`.

### What's inside
```
skills/task-observer/
├── SKILL.md                 when to observe, how to react to stalled/repeating/failed, loop-guard rules
└── scripts/
    ├── observe.py           run / wait / status / stop for long commands
    └── loop_guard.py        PostToolUse hook that detects agent loops
```

---

## record-skill

Record a workflow once and get a skill — like recording a macro. Instead of describing a procedure from memory, Claude builds the skill from the **real session transcript**: the steps that worked, the commands, the errors and how they were fixed, and — most valuable — every correction you gave along the way.

**Use it when** you say "start recording" … "stop recording", "turn what we just did into a skill", or "make a skill from yesterday's session".

### How it works
| Step | What happens |
|---|---|
| Record | "Start recording" saves a timestamp; you work normally; "stop recording" ends it. Or point at the current or a past session. |
| Digest | `transcript_digest.py` reads the Claude Code transcript (`~/.claude/projects/…/<session>.jsonl`) and compresses it: user prompts, one line per tool call, failures, short notes, files and commands summary. Secrets are redacted; long digests are cut from the middle. |
| Build | Claude extracts goal, inputs (parameters), the steps that survived, rules from your corrections, "if you see X" fixes, and verification; reusable commands go to `scripts/`. |
| Test | A fresh subagent gets only the new SKILL.md and a similar task with different inputs; the skill is fixed where it would go wrong. |

### Digest script
```bash
python3 skills/record-skill/scripts/transcript_digest.py list                 # sessions of this project
python3 skills/record-skill/scripts/transcript_digest.py digest latest --since 2026-10-30T07:00:00Z
python3 skills/record-skill/scripts/transcript_digest.py digest <id> --from-marker "deploy the" --no-text
```

### What's inside
```
skills/record-skill/
├── SKILL.md                     record modes, extraction rules, SKILL.md template, testing
└── scripts/
    └── transcript_digest.py     list sessions; digest one into a short, redacted timeline
```

---

## compaction-guard

Compaction keeps a summary and drops the rest — and the summary predictably loses your exact instructions, why decisions were made, which files were mid-change, and what was next. `compaction-guard` keeps that in a small state file and puts it back into context automatically after every compaction.

**Use it when** sessions get long, when Claude "forgets" instructions after `/compact` or auto-compact, or before a big multi-step task.

### How it works
| Layer | What it does |
|---|---|
| `NOW.md` | A ≤60-line state file Claude keeps current: goal, your instructions verbatim, decisions with reasons, in-progress files, next steps. Updated with small edits at milestones. |
| PreCompact hook | Writes `snapshot.md` from the transcript (first request, last user messages, files changed, recent failures — secrets redacted) and appends short "what to keep" instructions to the compaction prompt. Never blocks compaction. |
| SessionStart (`compact`) hook | Re-injects `NOW.md` + snapshot (kept under Claude Code's ~10k limit) right after compaction, so the next turn starts with the real state. |

### Setup
```bash
python3 skills/compaction-guard/scripts/guard.py install          # this project (.claude/settings.json)
python3 skills/compaction-guard/scripts/guard.py install --user   # all projects (~/.claude/settings.json)
python3 skills/compaction-guard/scripts/guard.py status           # what would be re-injected
```
Existing hooks are kept and a `.bak` is written; running it twice is safe; `uninstall` removes only its own hooks; `--on-clear` also re-injects after `/clear`. Restart Claude Code after installing.

### What's inside
```
skills/compaction-guard/
├── SKILL.md                 NOW.md format and update rules, what to do after compaction
└── scripts/
    └── guard.py             install / uninstall / precompact / sessionstart / status
```

---

## framework-upgrade

Claude's knowledge of breaking changes is frozen at training time, so upgrades go wrong the same ways: breaking changes guessed from memory, everything bumped at once, codemods skipped, warnings silenced and peer deps forced. `framework-upgrade` makes an upgrade **evidence-driven and incremental**.

**Use it when** you upgrade or migrate a framework, runtime or major dependency (React, Next.js, Angular, Vue, Node, TypeScript, .NET / EF Core, Django, Laravel, Rails, Spring Boot…), fix breakage after one, or want a plan first.

### How it works
| Step | What happens |
|---|---|
| Detect | `detect_versions.py` lists frameworks, runtimes, package managers, lockfiles and version drift across manifests (npm, NuGet, PyPI, Go, Composer, Gems, Maven/Gradle). |
| Baseline | Clean branch; build, tests, lint once; record exact pass/fail counts. |
| Research | Fetch the **official** guide for every major in between; grep each breaking change in your code (zero hits → dropped); check runtime and ecosystem compatibility; find official codemods. Plan goes to `UPGRADE.md`. |
| Execute | Tooling → codemods → bump with your package manager → fix compile → tests → deprecations; one commit per green step. |
| Verify | Compare with the baseline, count deprecations, run the app, update CI/Docker/runtime pins; QA list for changed defaults. |

Hard rules: no `--legacy-peer-deps`/`--force`, `skipLibCheck`, `@ts-ignore`, disabled warnings, skipped tests or old-version pins without your explicit yes.

### What's inside
```
skills/framework-upgrade/
├── SKILL.md                     scope, baseline, research, plan, execute, verify, report
├── scripts/
│   └── detect_versions.py       frameworks, runtimes, lockfiles, version drift
└── references/
    └── playbooks.md             where the official guides and codemods are, per ecosystem
```

---

## iran-payments

Payment code is where a small mistake costs real money, and it is where Claude most often guesses: it trusts the callback's `Status=OK`, writes gateway endpoints from memory, mixes Rial and Toman, and lets a refresh credit an order twice. `iran-payments` gives Claude one safe flow for every Iranian gateway and exact, sourced details for the common ones.

**Use it when** you add a payment gateway to a site, store backend or bot; write a request / callback / verify flow; fix a payment bug; or audit existing payment code ("review our ZarinPal integration").

### What it enforces
| Rule | Why |
|---|---|
| Callback is a hint; only server-side verify decides | The query string is user-controlled |
| Amount comes from your DB, compared on verify | Stops paying 1,000 and getting a 1,000,000 order |
| One unit internally: Rial as `long` | Rial/Toman ×10 bugs are the most common payment bug in Iran |
| Idempotent verify (status guard + unique token) | Refresh / double callback must not fulfil twice |
| Timeout ≠ failure → `Unknown` + reconcile job | Paid users are not cancelled because a request timed out |
| Anonymous, tenant-aware callback; per-tenant merchant ids | Works after the bank redirect; safe for multi-tenant stores |

### What's inside
```
skills/iran-payments/
├── SKILL.md                 the flow, 10 rules, payment row, review checklist
└── references/              loaded only for the gateway in use
    ├── zarinpal.md          REST v4: hosts, sandbox, request/verify, codes 100/101, error shape trap
    ├── zibal.md             v1: request/verify/inquiry, test merchant, result 100/201, amount check
    └── dotnet.md            entity, gateway interface, typed HttpClient, idempotent callback, reconcile job, tests
```
For any other PSP the skill tells Claude to fetch the official docs first instead of guessing endpoints.

---

## persian-rtl

Persian UIs break in two ways: **looks** (things flipped twice, arrows pointing the wrong way, `left/right` everywhere) and **data** (`ي`/`ك` and Persian digits stored as typed, so search misses results and `parseInt("۱۲۳")` is `NaN`). `persian-rtl` gives Claude one direction model and the data rules, and a lint script to measure the work.

**Use it when** you build or convert an RTL page, template, component or store front; fix RTL bugs; or audit a front end for Persian users ("convert this template to RTL", "why does search miss products with ی?").

### What it covers
| Area | Key rules |
|---|---|
| Direction | `dir="rtl"` in markup; flex/grid already follow it — never `row-reverse` for RTL; logical properties; the list of things that don't flip (translate, shadows, gradients, `scrollLeft`, JS math) |
| Icons | What to mirror (arrows, chevrons, pagination, send) and what never to (logos, media controls, checkmarks) |
| Text as data | Normalize `ي→ی`, `ك→ک`, `۰–۹/٠–٩→0–9` on input, search and storage; keep ZWNJ; bidi isolation for phones, e-mails, codes |
| Dates | UTC storage, Jalali display (`Intl` / `PersianCalendar`), `Asia/Tehran` with no DST since 2023, Saturday week start |
| Typography | OFL vs commercial Persian fonts (matters when you sell a template), no `letter-spacing`, line height, Persian punctuation |

### What's inside
```
skills/persian-rtl/
├── SKILL.md                 direction model, mirroring table, text/date rules, review workflow
├── scripts/
│   └── rtl_lint.py          physical CSS/Tailwind/JS styles, row-reverse, Arabic ي/ك → one line each
└── references/              loaded only when needed
    ├── css-tailwind.md      physical → logical mapping for CSS and Tailwind, Bootstrap/MUI notes
    ├── jalali.md            Jalali in JS and .NET, pickers, Tehran time zone, SQL reporting
    ├── typography.md        fonts and licenses, loading, digits, line height
    └── text-data.md         normalization (TS, C#, SQL), search, validation, slugs, sorting
```

### Lint
```bash
python3 skills/persian-rtl/scripts/rtl_lint.py src/            # one line per problem, exit 1 if any
python3 skills/persian-rtl/scripts/rtl_lint.py src/ --summary  # counts per rule only
```
Skips `node_modules`, build output and `*.min.*`; ignores `rtl:`/`ltr:` Tailwind variants and lines marked `rtl-ok`.

---

## Roadmap — Iranian dev stack
| Skill | Status | Scope |
|---|---|---|
| `iran-payments` | ✅ available | ZarinPal, Zibal, generic PSP rules, .NET reference |
| `persian-rtl` | ✅ available | RTL CSS/Tailwind, mirroring, bidi, ی/ک and digits, ZWNJ, Jalali dates, fonts, lint script |
| `bale-bot` | planned | Bale Bot API: where it differs from Telegram, limits, Bale payments |
| `ir-android-release` | planned | Signing, R8, ABI splits, Cafe Bazaar and Myket publishing checklist |

## Adding a skill
1. Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter (the folder name must match `name`).
2. Put runnable code in `scripts/` and long reference material in `references/`.
3. Add an entry to `.claude-plugin/marketplace.json` and a row to the table above.
4. Write a few pressure scenarios in `tests/<name>/scenarios.md` and walk through them after every change to the skill.

## License
[MIT](LICENSE) — free to use, modify and share, including commercially; keep the copyright notice.
