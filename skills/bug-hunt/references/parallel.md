# Parallel groups
Load this only when the user wants several groups fixed at the same time.

Only for groups in different modules with no shared root cause. Never two sessions in one working tree (bin/obj locks, ledger overwrites). The coordinator (this session), per group:
```bash
git worktree add ../wt-<group> -b bughunt/<group> <main>
mkdir -p ../wt-<group>/.bughunt && cp .bughunt/*.sh .bughunt/*.py .bughunt/module-re .bughunt/map.md ../wt-<group>/.bughunt/
cp .ignore ../wt-<group>/ 2>/dev/null
```
(`info/exclude` is shared by all worktrees of a repo, so `.bughunt/` and `.ignore` are already excluded there.)

Write the ledger header (with that group's `Base:`) plus its rows to `../wt-<group>/.bughunt/ledger.md`. Each parallel session opens in its own worktree, runs the normal fix loop there, and touches nothing outside it. Worker sessions do per-bug reviews (step 8) but no group review — the coordinator runs one group review per branch before merging, so no review is paid twice.

When they finish, the coordinator copies the rows back into the main ledger by ID, reviews each branch, merges them one at a time (or opens one PR each, per `map.md`), and runs the end-of-group checks once on the result. Then `git worktree remove ../wt-<group>` for each.

With the Orchestra skill installed, each group is one stream whose owned paths are its module folders.
