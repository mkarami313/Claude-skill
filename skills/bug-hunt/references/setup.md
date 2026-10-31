# Phase 0 — Setup (once per repo)
Load this only when `.bughunt/` does not exist yet in the repo.

`<skill-dir>` is this skill's base directory (shown when the skill loads). If it has no `scripts/` folder (the skill was uploaded as a single SKILL.md), fetch the full skill once, **pinned to a tag** so the scripts you run are the ones that were reviewed, and use the copy as `<skill-dir>`:
```bash
[ -d <skill-dir>/scripts ] || { git clone -q --depth 1 --branch bug-hunt-v2 https://github.com/mkarami313/Claude-skill .bughunt/src && echo "skill-dir=.bughunt/src/skills/bug-hunt"; }
```
If the clone fails (tag missing, no network), stop and ask the user to attach the skill's `scripts/` folder — never re-type the scripts from memory.

Then:
```bash
mkdir -p .bughunt/dossiers
cp <skill-dir>/scripts/* .bughunt/ && chmod +x .bughunt/*.sh
EX=$(git rev-parse --git-path info/exclude)          # works in worktrees and submodules too (.git may be a file)
mkdir -p "$(dirname "$EX")"
grep -qxF '.bughunt/' "$EX" || echo '.bughunt/' >> "$EX"   # local only, no tracked change
```
1. **Module regex** → `.bughunt/module-re`: one regex matching a module in a file path, e.g. `src/Modules/[^/]+`. The build script clusters errors by it.
2. **Token-trap filter.** If the repo has no `.ignore`, create one so every Grep/Glob skips generated and huge files, then add `.ignore` to the same exclude file (`grep -qxF '.ignore' "$EX" || echo '.ignore' >> "$EX"`):
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
3. **Environment check** — before triage, confirm what the tests need is up: database/connection string, Docker (Testcontainers), required env vars/secrets. Write what's needed and how to start it into `map.md`. Failures caused by a missing environment are not code bugs (see `env` in the ledger).
4. **Map** → `.bughunt/map.md`, written once (≤70 lines) by a sonnet subagent, so no session re-explores the repo:
   - Backend: solution; projects by module (`dotnet sln list`); test project per module; host; DI registration; DbContexts; migrations; tenant resolution; background jobs; test platform (VSTest, or Microsoft.Testing.Platform if `global.json` says so) and framework (xUnit v2/v3, NUnit, MSTest); what the tests need to run (DB, Docker, env vars).
   - Frontend: web root(s); package manager; tsconfig that is type-checked; unit test runner; e2e (Playwright?); routes → page folders; API client (generated? regenerate command); data-fetching/state library.
   - Git: the main/integration branch name, and whether fixes go in by local merge or by PR.
   - What `.ignore` hides; the project's own skill, if any — later load only the target module's files from it.
