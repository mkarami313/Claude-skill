# Finding the root cause
Load this when the cause is not obvious after reading the failing method and its direct callers. Work through the steps in order; stop as soon as one gives you a cause you can prove.

**Iron law: no fix without a root cause you can point to** (file:line plus the evidence that it is the cause). A symptom fix is a failed fix.

## 1. Read the evidence you already have
- The whole error message and the first stack frame **in our code** (the triage row already has it). Error codes (CS, TS, EF, HTTP status, ProblemDetails `type`) often name the fix.
- What changed: `git log --oneline -15 -- <module path>` and `git diff <last-green>..HEAD --stat -- <module path>`. A bug that appeared after a commit is usually in that commit's diff.

## 2. Trace backward to the original trigger
The line that throws is rarely the line that is wrong. Ask "where did this bad value come from?" and walk up one caller at a time until you reach the place that **created** the bad value (a mapper, a default, a query filter, a missing `await`, a test fixture). Fix there, not where it exploded.
- More than ~3 hops or >400 lines to read → haiku/sonnet subagent: `TASK: trace where <value> gets <bad state> before <file:line>. RETURN: ≤10 lines, the call chain with file:line, and the first place the value is wrong.`

## 3. Instrument the boundaries (multi-layer bugs)
When a request crosses layers — React → API client → controller → handler → EF → DB, or job → scope → tenant → DbContext — don't guess which layer breaks. Add **temporary** logging at each boundary, run the repro once, and read only the probe lines:
- .NET: `Console.Error.WriteLine($"BH1 tenant={_tenant.Id} order={id}");` — in tests, `ITestOutputHelper` or `Console.Error` (the logger may be filtered).
- React: `console.error('BH1', { key, tenantId })`.
- Run, then `grep -h 'BH[0-9]' .bughunt/test.log .bughunt/web-test.log | head -30`.
- The first boundary where the value is wrong is where to look. **Remove every `BH` probe before the commit** (`git diff HEAD | grep -n 'BH[0-9]'` must be empty).

## 4. Compare with something that works
Find the closest **working** twin in the codebase (another module's handler, the same endpoint for another entity, the same component on another page) with one Grep. List every difference, however small — a missing `[Authorize]`, `AsNoTracking`, `IgnoreQueryFilters`, query-key part, `await`. The bug is usually in that list.

## 5. One hypothesis, one variable
Write the hypothesis in the ledger Notes before testing it: `H1: cache key lacks tenant → second tenant reads first tenant's list`. Then make the **smallest** change that would prove or disprove it, run only the repro, read `exit=`. Wrong → revert that change completely, then form H2 from the new evidence. Never stack a second change on top of a failed one.

## 6. Escalation ladder
- **2 wrong hypotheses** → dossier (`.bughunt/dossiers/BUG-xxx.md`, ≤40 lines: symptom, repro command, files:lines, hypotheses and why rejected, probe output) → opus subagent: "find the root cause, return ≤15 lines". Give it the dossier only, never the conversation.
- **3 failed fixes in total** (yours + the one from the opus answer) → stop fixing. This is usually not a bug but a design problem: each fix exposes a new problem in another place, or the fix would need a large refactor. Set status `needs-decision`, add to the dossier a "Design question" section (what is coupled, two options with their cost), tell the user, and move on to the next bug. Do not try fix #4.

## Flaky tests
Mixed results over 3 runs. Find which kind before fixing:
- **Timing** — the test waits with `Task.Delay`, `Thread.Sleep`, `setTimeout`, fixed `waitForTimeout`. Fix: wait for the condition, not for time. .NET: poll the condition with a deadline, or inject `TimeProvider` and use `FakeTimeProvider.Advance`. React: `await screen.findBy…` / `waitFor(() => …)`, or `vi.useFakeTimers()` + `vi.advanceTimersByTime`. Playwright: web-first assertions (`await expect(locator).toHaveText(…)`), never `waitForTimeout`. Keep a fixed delay only when the test is *about* timing (debounce, retry backoff), with a comment saying why.
- **Pollution** — passes alone, fails with the others: another test leaves state behind (static field, shared DB rows, singleton cache, env var, mocked clock never restored, module-level store). Find the polluter by bisection: `bash .bughunt/polluter.sh dotnet <Tests.csproj> <TestName>` or `bash .bughunt/polluter.sh web <web-dir> <test-file>`. Fix the polluter's cleanup (or give the shared fixture per-test isolation), not the victim.
- **Order/parallelism** — xUnit runs collections in parallel: two classes writing the same table or the same static. Put them in one `[Collection]` or isolate the data (unique tenant/ids per test).
- **Real race in product code** — the flake is the bug. Treat it as `async`/concurrency (opus-class).

## After the fix: make it hard to come back (S0 only)
For S0 bugs (tenant leak, wrong money, auth bypass, data loss) one guard at the layer that would have caught the whole class is worth it — e.g. a `SaveChanges` interceptor that refuses an entity without `TenantId`, a `decimal` precision convention, a policy on the resource, an architecture test that fails when a new entity has no query filter. Put it in a **separate commit** right after the fix and name it in the review package. For S1–S3: the minimal fix only.

## Red flags — stop and go back to step 1
| Thought | Reality |
|---|---|
| "It's probably X, let me just change it" | That is a guess. Write the hypothesis and the evidence that would prove it. |
| "Let me try two changes at once" | Then you can't tell which one worked, or what the other broke. |
| "One more fix" (after two failed) | Go to the escalation ladder. |
| "I'll write the test after the fix" | A test you never saw fail proves nothing. |
| "The test passes now, done" | Did it fail before for the reason in the ledger? Did the module's tests also pass? |
| "Add a null check / try-catch here" | That hides the symptom. Where does the null come from? |
| "The subagent said it's fixed" | Run the repro yourself and read `exit=`. |
