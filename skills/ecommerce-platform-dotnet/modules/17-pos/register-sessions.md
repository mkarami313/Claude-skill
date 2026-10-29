# 17 · Register sessions & cash control

## Model
- `Register`: a physical till, tied to a warehouse/store location.
- `RegisterSession`: `Id`, `RegisterId`, `CashierUserId`, opened-at, opening float,
  closed-at, counted cash, expected cash, variance, status (Open | Closed).
- `CashMovement`: pay-in / pay-out / drop during a session, with reason.

## Workflow
- Open session with a starting cash float.
- Sales and cash movements accrue to the session.
- Close: count cash → compute expected (float + cash sales − payouts) → record variance →
  `RegisterSessionClosed` (accounting 06 posts cash + variance).

## Rules
- One open session per register at a time; only the assigned cashier (or manager) operates it.
- Variance over a threshold requires manager approval; audited.

## API surface
- Open/close session; record cash movement; session X/Z report (sales + cash summary).
