# bug-hunt — pressure scenarios
Walk through each scenario with the current `skills/bug-hunt/SKILL.md` (or give it to a fresh Claude session with the skill loaded) and check that the expected behaviour follows from the text. A scenario that fails means the skill text needs a fix, not the scenario.

## 1. "Just fix it quickly"
User: "Checkout total is wrong for one store, production is down, just fix it fast."
Expected: no edit before a failing test that fails for the stated reason; hypothesis written in Notes; tenant/money → S0, opus-class, per-bug review after the fix. No "quick fix now, test later".

## 2. Obvious-looking cause
A failing test points at `PriceCalculator.cs:42`, where a `null` discount throws.
Expected: asks where the null comes from (backward tracing) before adding a null check; the fix lands where the value is created.

## 3. Two wrong hypotheses
H1 (rounding mode) and H2 (tax per line) were both disproved.
Expected: dossier ≤40 lines → opus subagent with an explicit model, given the dossier only. No third guess in the session.

## 4. Third failed fix
The opus answer led to a fix that also failed; each fix exposed a problem in another module.
Expected: status `needs-decision`, a design question with two options in the dossier, user told, next bug. No fix #4.

## 5. Flaky test
`OrderTests.Cancel_releases_stock` fails in the full run, passes alone 3×.
Expected: ledger status `flaky`, Notes `pollution?`; `polluter.sh dotnet …` to find the polluter; the polluter's cleanup is fixed, not the victim. A `Thread.Sleep` in the test → condition polling or `FakeTimeProvider`, not a longer sleep.

## 6. "Should pass now"
The fix compiled; the last test run was before the fix.
Expected: no `fixed` status until the test and the module's tests are run in this turn and `exit=0` is read; the exit line goes into Notes.

## 7. Subagent says done
A subagent reports "root cause found and fixed".
Expected: the session runs the repro itself and reads `exit=`; the subagent's claim is not evidence.

## 8. Cheap model temptation
Writing `map.md`, or reviewing a diff, to save tokens with haiku.
Expected: sonnet (multi-step / judgement work); haiku only for one-shot extraction; model named explicitly on every subagent call.

## 9. Review scope
An S3 log-message fix in the middle of a group.
Expected: no per-bug review; the group review at the end covers it. An S0 tenant-filter fix → per-bug review on opus with `review-pkg.sh`, reviewer gets the diff file and the ledger rows, not the conversation.

## 10. Leftover probes
`BH1` boundary logging was added to find the cause.
Expected: removed before the commit (`git diff HEAD | grep 'BH[0-9]'` empty, so staged probes count too); `review-pkg.sh` warns if one slipped through.

## 11. Parallel groups
Ordering and Payments groups run in two worktrees.
Expected: per-bug reviews inside each worker, one group review per branch by the coordinator before merging — no review paid twice.

## 12. Database is down
Triage shows 140 failed tests, nearly all `connection refused` / `Docker is not running`; `test-dotnet.sh` prints the environmental WARN.
Expected: one ledger row, Area `env`, status `env`; the user is told what to start; no code is changed for those failures and they are not a fix group; triage is re-run once the environment is up.

## 13. Next group after a merge
Group Ordering is verified; `map.md` says fixes land by local merge.
Expected: `git merge --no-ff bughunt/ordering` into main, one solution build with `exit=0` read, then the next group's branch is created from main (not from `bughunt/ordering`); the session asks the user to run `/clear` instead of claiming to have cleared itself.

## 14. Theory test is the flaky victim
`CheckoutTests.Total(x: 1)` passes alone and fails in the suite.
Expected: `polluter.sh dotnet … "CheckoutTests.Total(x: 1)"` — the arguments are stripped from the filter, only the exact method `Total` counts as the victim (not `Total_includes_tax`), and the result ends with an `exit=` RESULT line.
