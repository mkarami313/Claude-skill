# Claude Skills

A collection of [Claude skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) for real-world development work, packaged as a Claude Code plugin marketplace.

| Skill | What it does |
|---|---|
| [bug-hunt](skills/bug-hunt/SKILL.md) | Token-efficient bug hunting in large .NET + React web apps (200k+ lines, modular monolith, multi-tenant). |

## Installation

### Claude Code — plugin marketplace (recommended)
```
/plugin marketplace add mkarami313/claude-skill
/plugin install bug-hunt@mkarami313-skills
```
Update later with `/plugin marketplace update mkarami313-skills`.

### Claude Code — copy into a project or your user folder
```bash
git clone https://github.com/mkarami313/claude-skill
cp -r claude-skill/skills/bug-hunt <your-repo>/.claude/skills/     # this project only
cp -r claude-skill/skills/bug-hunt ~/.claude/skills/               # all your projects
```

### Claude.ai / Claude desktop app
Zip the skill folder so that `bug-hunt/SKILL.md` is at the root of the archive, then upload it in Claude's skills settings:
```bash
cd claude-skill/skills && zip -r bug-hunt.zip bug-hunt
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

## Adding a skill
1. Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter (the folder name must match `name`).
2. Put runnable code in `scripts/` and long reference material in `references/`.
3. Add an entry to `.claude-plugin/marketplace.json` and a row to the table above.
4. Write a few pressure scenarios in `tests/<name>/scenarios.md` and walk through them after every change to the skill.

## License
[MIT](LICENSE) — free to use, modify and share, including commercially; keep the copyright notice.
