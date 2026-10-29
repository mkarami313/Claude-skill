# Review gate
An independent reviewer reads the diff, not the conversation, so the fix is not grading itself.

## When
- **Per bug:** S0, and any fix that touches money, tax, accounting, tenant isolation, auth or a migration.
- **Per group:** once at the end of every group, over the whole group branch (`BASE` = where the branch started).
- Not for S2/S3 fixes inside a group — the group review covers them.

## How
1. Record `BASE` before the first change (`git rev-parse HEAD`, also written in the ledger header as `Base:`).
2. `bash .bughunt/review-pkg.sh <BASE> <BUG-xxx|group-name>` → prints the path of one file with commits, stat and full diff. Its contents never enter your context.
3. Dispatch a subagent with an **explicit model** (an omitted model inherits the session's, usually the most expensive): **sonnet** as the floor, **opus** for S0 and for the group review of an opus-class group. Never haiku — cheap models take 2–3× the turns on a judgement task and end up costing more.
4. Fill in the brief below. Give file paths, never paste the diff or the conversation.

## Brief
```
You review one bug fix (or one group of fixes) in a .NET + React multi-tenant app. Read-only: do not edit files, switch branches, commit, or spawn subagents.

WHAT WAS REQUESTED — ledger rows:
<paste the ledger rows: ID | Sev | Module | Symptom | Evidence | Notes (root cause)>

DIFF: read <path printed by review-pkg.sh> once. It is your view of the change; open other files only to check a concrete risk you name (e.g. "other callers of the changed method"), one focused check per risk.

The fixer's claims (root cause, "tests pass") are unverified — judge the code. Do not re-run the suite; run one focused test only if the code raises a specific doubt no existing run answers.

CHECK
1. Spec: does the change fix the root cause stated in Notes, at its source, not the symptom? Does each bug have a test that would fail without the fix and hits real code (mocks only at external boundaries: gateway, clock, email, SMS)?
2. Scope: anything beyond the fix (refactors, renames, formatting, unrelated files)? Leftover debug probes (`BH1`, console.error, Console.WriteLine)?
3. Risk: tenant scoping (queries, cache keys, jobs, files), money/decimal/rounding, auth on the resource (IDOR), async/await and CancellationToken, EF tracking/concurrency, migrations that lose data, API↔React contract changes without the client updated.

RETURN ≤15 lines:
VERDICT: approve | changes-needed
- [Critical|Important|Minor] file:line — finding — why it matters
```

## Acting on the verdict
- **Critical / Important** → fix in this session (same bug ID), re-run the repro and the module tests, regenerate the package for the new range only, and send it to the same reviewer model. Two rounds without approval → status `needs-decision`, tell the user.
- **Minor** → note in the ledger, don't loop on it.
- Disagree with a finding? Write one line of evidence (file:line, test) in Notes; don't silently ignore it.
