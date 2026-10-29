---
name: bug-hunt
description: Token-efficient bug hunting in a large .NET + React web app (200k+ lines, modular monolith, multi-tenant). Use when finding, triaging or fixing bugs, build/type/lint errors or failing tests in the C#/.NET backend or the React/TypeScript frontend, when resuming a bug-fixing session, or on /bug-hunt.
---

# Bug Hunt — large .NET + React web apps

Debugging 200k+ lines burns tokens four ways: reading too much code, reading raw logs, cold-starting agents for small jobs, and keeping one session alive too long. The **ledger** on disk is your memory; your context is disposable. The filtering lives in this skill's `scripts/` — run them, never re-type them.

## Golden rules
1. **Never read a large file whole.** Grep with `path` = the module folder, a `type`/`glob`, and `output_mode: files_with_matches` or `head_limit`; then Read only the range you need (40–120 lines).
2. **Never read raw build/test/lint output.** Use the `.bughunt/*.sh` scripts: they log to files and print a summary. Never pipe a running build into `head` (SIGPIPE can kill it and the exit code is lost) — write to a file, then read its head.
3. **Do it yourself first; delegate only reading volume.** A subagent starts cold (thousands of tokens of overhead); a repo-wide Grep for file names is cheaper. Delegate when the job means reading more than ~400 lines (a log, a call chain, a big file). The subagent returns ≤10 lines.
4. **The ledger is the memory.** Update it after each bug. After one group (or ~4–5 bugs, or when context gets long) end the session (`/clear`); the next one resumes from the ledger.
5. **Repro first, then fix:** a failing test — or, for build/type errors, the build command itself. No refactors, no "while I'm here" edits.
6. **Build/test the smallest unit:** one project, one test, one test file. Whole solution and whole web app only at triage and at the end of a group.
7. **One group per session** — same module or same root cause.
8. **Silence is not green.** An empty error list means nothing unless `exit=0`. Every script prints `exit=` first; read it.

## Models
The **session** writes tests and fixes; its model is the user's choice (`/model`). Subagents get a model per call.

| Work | Who | Model |
|---|---|---|
| Log/TRX triage, wide reads, call-chain maps, writing map.md | subagent | haiku |
| Normal bug: cause located, test, fix | this session | sonnet is enough |
| Root cause unknown after 2 hypotheses; concurrency/async; money, accounting, tax; tenant isolation; auth; migrations | dossier → subagent, or run the whole group in an opus session | opus |

When planning, mark each group's session model. If a group is opus-class and this session isn't, tell the user to switch with `/model` before starting it.

Subagent prompt: `TASK: … SCOPE: <folders/files> RETURN: ≤10 lines — file:line + one-line finding each. No code.`

---

## Phase 0 — Setup (once per repo)
`<skill-dir>` is this skill's base directory (shown when the skill loads).
```bash
mkdir -p .bughunt/dossiers
cp <skill-dir>/scripts/* .bughunt/ && chmod +x .bughunt/*.sh
grep -qxF '.bughunt/' .git/info/exclude || echo '.bughunt/' >> .git/info/exclude   # local only, no tracked change
```
1. **Module regex** → `.bughunt/module-re`: one regex matching a module in a file path, e.g. `src/Modules/[^/]+`. The build script clusters errors by it.
2. **Token-trap filter.** If the repo has no `.ignore`, create one so every Grep/Glob skips generated and huge files, then add `.ignore` to `.git/info/exclude`:
   ```
   **/Migrations/*.Designer.cs
   **/Migrations/*ModelSnapshot.cs
   **/wwwroot/lib/
   **/dist/
   **/*.min.js
   **/*.min.css
   <generated API client folder>
   ```
   For a migration bug, search those files with Bash `rg --no-ignore-dot`.
3. **Map** → `.bughunt/map.md`, written once (≤70 lines) by a haiku subagent, so no session re-explores the repo:
   - Backend: solution; projects by module (`dotnet sln list`); test project per module; host; DI registration; DbContexts; migrations; tenant resolution; background jobs; test platform (VSTest, or Microsoft.Testing.Platform if `global.json` says so) and framework (xUnit v2/v3, NUnit, MSTest).
   - Frontend: web root(s); package manager; tsconfig that is type-checked; unit test runner; e2e (Playwright?); routes → page folders; API client (generated? regenerate command); data-fetching/state library.
   - What `.ignore` hides; the project's own skill, if any — later load only the target module's files from it.

## Phase 1 — Triage (no fixing)
**Backend build** (whole solution, once): `bash .bughunt/build.sh <Solution>.sln`
→ `exit= errors=`, clusters by error code and module, first 40 errors (all: `.bughunt/build-errors.txt`). Catches C#, MSBuild, NuGet and Razor errors. Many errors with one code in one module usually have one cause (changed interface, renamed type, missing using/package) → log the cluster as **one** bug.

**Backend tests** (only when the build is green): `bash .bughunt/test-dotnet.sh <Solution>.sln`
→ `exit= trx= failed=`, then `test | message | file:line` per failure, including timeouts, aborts and test-host crashes. Detects Microsoft.Testing.Platform (.NET 10) and switches flags.

**Frontend** (per web root): `bash .bughunt/web-triage.sh <web-dir>`
→ tsc, ESLint and unit-test results as one-line rows with counts (`ts-errors.txt`, `lint-errors.txt`, `failed-web.txt`). `TSCONFIG=<file>` overrides the tsconfig if it picked the wrong one.

**Flaky check** before logging a test bug — rerun only that test 3×:
`for i in 1 2 3; do bash .bughunt/test-dotnet.sh <Module.Tests>.csproj "<TestName>" | head -1; done`
(web: run `vitest run <file> -t "<name>"` 3×). Mixed results → `flaky` (shared state, clock, ordering, async).

**Other sources** (user reports, production logs, reviews): a haiku subagent extracts `exception | message | top frame in our code | count`. Never read logs yourself.

### Ledger (`.bughunt/ledger.md`)
```
# Bug ledger
Build: red 2026-10-29   Tests: 12/3400 failed   Web: tsc 4 · lint 9 · tests 2 failed
Next group: Ordering (sonnet)
Groups: Ordering (sonnet) · Payments (opus) · web/checkout (sonnet)

| ID | Sev | Area | Module | Symptom (one line) | Evidence (file:line / test) | Status | Notes |
|----|-----|------|--------|--------------------|-----------------------------|--------|-------|
| BUG-001 | S1 | api | Ordering | total ignores tax | CheckoutTests.Total_includes_tax | new | |
```
- Area: `api`, `web`, or `contract` (backend↔frontend mismatch).
- Status: `new → repro → fixing → fixed → verified` (or `flaky`, `wontfix`, `needs-decision`).
- Keep ≤150 rows; move `verified` rows to `.bughunt/done.md`.
- Severity, fix in this order: **S0** build broken, data loss, tenant leak, auth bypass, wrong money · **S1** main flow broken (checkout, payment, order, login) · **S2** secondary flow wrong, user-visible slowness · **S3** cosmetic, logging.

## Phase 2 — Group and plan
Group by module, then by shared root cause; a contract bug joins the backend module that owns the DTO. S0 first. Fill `Next group:` and `Groups:`. Show the user a short table (group · bugs · severity · session model) and start — ask only when a fix needs a product decision.

## Phase 3 — Fix loop
**Start of session:**
```bash
sed -n '1,6p' .bughunt/ledger.md; grep -F "| <Module> |" .bughunt/ledger.md
git switch bughunt/<group> 2>/dev/null || git switch -c bughunt/<group>
```
Read only the relevant part of `map.md`. Do not re-triage.

**Per bug:**
1. **Locate** — Grep the symbol/message inside the module path; Read the method and its direct callers. Wider chain → haiku subagent.
2. **Checklist** — load only now, only the matching one: `<skill-dir>/references/checklist-dotnet.md`, `checklist-react.md`, or `checklist-contract.md` (API↔React, Persian text, payment gateways).
3. **Reproduce** → status `repro`. It must fail for the reason in the ledger.
   - Backend: smallest test in the module's test project, in its existing style. `bash .bughunt/build.sh <Module.Tests>.csproj` then `bash .bughunt/test-dotnet.sh <Module.Tests>.csproj "<TestName>"`.
   - Frontend: test beside the component (Testing Library), only that file: `vitest run <file> -t "<name>"` or `jest <file> -t "<name>"` via the package manager, output to a file, then `tail -20`. Flow-level UI bug with Playwright present → one spec, `--reporter=line`.
   - Build/type error: the build or tsc command is the repro.
4. **Root cause** — state a hypothesis and the evidence that would confirm it, then check. After **two** wrong hypotheses: write `.bughunt/dossiers/BUG-xxx.md` (≤40 lines: symptom, repro command, files:lines, hypotheses and why rejected) and give only that to an opus subagent: "find the root cause, return ≤15 lines".
5. **Fix** — minimal, at the root cause, not the symptom. Status `fixing`.
6. **Verify** — the new test, then the module's test project (or that feature's web test files). Status `fixed`.
7. **Record** — ledger row (root cause ≤1 line in Notes), then `git commit -m "fix(<module>): BUG-xxx <what>"`.

**End of group:** run the triage commands once for the solution and the web root. New failures → new ledger rows, not fixes now. Mark the group `verified`, set `Next group`, end the session (`/clear`).

## Parallel groups
Only for groups in different modules with no shared root cause. Never two sessions in one working tree (bin/obj locks, ledger overwrites). The coordinator (this session), per group:
```bash
git worktree add ../wt-<group> -b bughunt/<group>
mkdir -p ../wt-<group>/.bughunt && cp .bughunt/*.sh .bughunt/*.py .bughunt/module-re .bughunt/map.md ../wt-<group>/.bughunt/
cp .ignore ../wt-<group>/ 2>/dev/null
```
Write the ledger header plus that group's rows to `../wt-<group>/.bughunt/ledger.md`. Each parallel session opens in its own worktree, runs the normal fix loop there, and touches nothing outside it. When they finish, the coordinator copies the rows back into the main ledger by ID, merges the branches, and runs the end-of-group checks once on the result. With the Orchestra skill installed, each group is one stream whose owned paths are its module folders.

## Reporting
After each group: a short table — bug · root cause (one line) · fix · test — plus what remains and the next group. No code dumps, no step-by-step recap.
