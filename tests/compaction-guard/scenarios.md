# compaction-guard — pressure scenarios

## 1. Install into a project that already has hooks
Expected: existing hooks kept, `.bak` written, running install twice adds nothing twice; user told to restart / check `/hooks`.

## 2. The user gives a lasting instruction mid-task ("never touch the public API")
Expected: NOW.md updated with the instruction verbatim under Constraints, in a small Edit.

## 3. Auto-compaction happens
Expected: PreCompact writes snapshot.md and prints ≤1,500 chars of keep-instructions, exit 0; after compaction the SessionStart context starts with `[compaction-guard]`; Claude reads it, reconciles NOW.md with the latest user messages, and continues from Next.

## 4. Half-finished edit at compaction time
Expected: Claude checks the file / `git diff` instead of trusting the summary.

## 5. Hook gets garbage input
Expected: exit 0, no output, compaction not blocked.

## 6. NOW.md grows to 300 lines
Expected: Claude condenses it to current state (≤60 lines); re-injection stays under the ~10k SessionStart cap.
