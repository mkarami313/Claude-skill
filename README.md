# Claude Skills

A collection of [Claude skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) for real-world development work, packaged as a Claude Code plugin marketplace.

| Skill | What it does |
|---|---|
| [bug-hunt](skills/bug-hunt/SKILL.md) | Token-efficient bug hunting in large .NET + React web apps (200k+ lines, modular monolith, multi-tenant). |
| [ecommerce-platform-dotnet](skills/ecommerce-platform-dotnet/SKILL.md) | Build a comprehensive, multi-tenant (white-label) e-commerce platform backend in C#/.NET 10, module by module, with OWASP ASVS L2 security. |

## Installation

### Claude Code — plugin marketplace (recommended)
```
/plugin marketplace add mkarami313/claude-skill
/plugin install bug-hunt@mkarami313-skills
/plugin install ecommerce-platform-dotnet@mkarami313-skills
```
Update later with `/plugin marketplace update mkarami313-skills`.

### Claude Code — copy into a project or your user folder
```bash
git clone https://github.com/mkarami313/claude-skill
cp -r claude-skill/skills/<skill> <your-repo>/.claude/skills/     # this project only
cp -r claude-skill/skills/<skill> ~/.claude/skills/               # all your projects
```

### Claude.ai / Claude desktop app
Zip the skill folder so that `<skill>/SKILL.md` is at the root of the archive, then upload it in Claude's skills settings:
```bash
cd claude-skill/skills && zip -r <skill>.zip <skill>
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
| 3. Fix loop | Per bug: locate → failing test → root cause → minimal fix → verify → ledger row → commit on a `bughunt/<group>` branch. After two wrong hypotheses it writes a short dossier and escalates to an Opus subagent. |

### What's inside
```
skills/bug-hunt/
├── SKILL.md                      workflow, rules, ledger format
├── scripts/
│   ├── build.sh                  dotnet build → error list clustered by code and module
│   ├── test-dotnet.sh            dotnet test (VSTest or Microsoft.Testing.Platform) → one line per failure
│   ├── web-triage.sh             tsc + ESLint + vitest/jest → one line per problem
│   └── bh.py                     parser for TRX, JUnit XML, Jest JSON and ESLint JSON
└── references/                   loaded only while looking for a root cause
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
- **Parallel groups** run in separate git worktrees, so builds and the ledger never collide.

### Requirements
- .NET SDK (tested layout: .NET 8–10; xUnit, NUnit or MSTest)
- Node.js with npm, pnpm or yarn for the frontend
- `bash` (Git Bash or WSL on Windows) and Python 3

### Notes
- With Microsoft.Testing.Platform, the single-test filter defaults to xUnit v3's `--filter-method`; set `BH_MTP_FILTER=vstest` for MSTest/NUnit.
- If the frontend type-checks a different tsconfig, run `TSCONFIG=<file> bash .bughunt/web-triage.sh <web-dir>`.

## ecommerce-platform-dotnet

A skill for building a **comprehensive, multi-tenant (white-label) e-commerce platform backend** in C#/.NET 10 — the kind of core that any store can run on. It is designed to be handed to Claude Code for implementation: one big spec would blow the context window, so the skill is a **router** over small, single-topic files, and Claude opens only the files for the task in front of it.

**Use it when** implementing or changing any part of this platform's backend — architecture, multi-tenancy, catalog, inventory, ordering, payments, accounting, shipping, customers/auth, marketing, search, marketplace, subscriptions, POS, B2B, Iran compliance, infrastructure, AI — and whenever the work must follow OWASP Top 10 + OWASP ASVS Level 2. It is **not** for a different stack, an unrelated codebase, frontend work, or quick e-commerce Q&A (the skill has a "When NOT to use" section).

### How it works
`SKILL.md` is a thin router: it holds the locked technical decisions and a table that maps a topic to one module folder. For a task, Claude reads the security checklist, the coding standards, the module's `_index.md`, and only the one or two sub-files it needs — never the whole tree. Each module is a folder split into short sub-files so no single file is large.

### What's inside
```
skills/ecommerce-platform-dotnet/
├── SKILL.md                    router: locked decisions, module map, build phases
├── modules/                    27 modules, each a folder of short sub-files + an _index.md
│   ├── 00-architecture/        layout, building blocks, contracts, cross-module data map
│   ├── 01-multitenancy/ … 21-ai/        catalog, inventory, ordering, payments, accounting,
│   │                                    purchasing, shipping, auth/CRM, marketing, content/SEO,
│   │                                    search, marketplace, localization/tax, notifications,
│   │                                    analytics, POS, HR, B2B, infrastructure, AI
│   ├── 22-gift-cards/  23-subscriptions/  24-data-import/
│   └── 25-admin-backoffice/  26-iran-compliance/   (سامانه مؤدیان + E-Namad)
├── reference-implementation/   canonical C# style anchor (cross-cutting + one full vertical slice)
├── security/                   OWASP Top 10 + ASVS L2 checklist, secure .NET patterns
├── standards/                  coding, testing, error-codes, idempotency
└── assets/                     Directory.Build.props, Directory.Packages.props, .editorconfig,
                                scaffold/ (new-solution.sh, new-module.sh)
```

### Locked decisions (the skill won't re-litigate these)
.NET 10 · ASP.NET Core Controllers + REST · modular monolith, Clean Architecture + DDD · shared-DB multi-tenancy with an EF global filter · PostgreSQL + EF Core · ASP.NET Identity + JWT + OTP · redirect-only payment gateways (no stored card data) · Redis + Hangfire + Serilog/OpenTelemetry · OpenSearch + pgvector · optimistic concurrency via `xmin` · xUnit + Testcontainers · Docker · OWASP ASVS Level 2.

### Design choices that keep it usable
- **Router, not a monolith.** Claude loads a handful of small files per task instead of one giant document, so context stays small and consistent.
- **Security is not optional.** One checklist is mandatory for every module, and the secure-patterns file is read whenever auth, input, crypto, uploads or payments are touched.
- **A style anchor.** `reference-implementation/` gives one fully worked vertical slice plus the cross-cutting patterns (Result, tenant interceptor, outbox, validation), so every module comes out looking the same.
- **Scaffolding.** `assets/scaffold/*.sh` create the solution and each module's four projects wired the right way, so the structure never drifts.
- **Built for the Iranian market.** First-class RTL/Persian, Iranian redirect gateways, Bale bot channel, and a compliance module for سامانه مؤدیان and نماد اعتماد الکترونیک.

### Requirements
- .NET 10 SDK · PostgreSQL · Redis · an OpenSearch instance (for search/vectors) · Docker (for Testcontainers and deployment)

## Adding a skill
1. Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter (the folder name must match `name`).
2. Put runnable code in `scripts/` and long reference material in `references/`.
3. Add an entry to `.claude-plugin/marketplace.json` and a row to the table above.

## License
[MIT](LICENSE) — free to use, modify and share, including commercially; keep the copyright notice.
