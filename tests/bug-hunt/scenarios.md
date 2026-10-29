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
Expected: removed before the commit (`git diff | grep 'BH[0-9]'` empty); `review-pkg.sh` warns if one slipped through.

## 11. Parallel groups
Ordering and Payments groups run in two worktrees.
Expected: per-bug reviews inside each worker, one group review per branch by the coordinator before merging — no review paid twice.
