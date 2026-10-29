# 23 · Subscription lifecycle

## Model
- `Subscription`: `Id`, `TenantId`, `CustomerId`, `PlanId`, `Status`
  (Trialing | Active | PastDue | Paused | Cancelled | Expired), `CurrentPeriodStart/End`,
  `CancelAtPeriodEnd` flag, payment mandate reference (05).

## State transitions (enforce in the domain)
- `Trialing → Active` at first successful charge after the trial.
- `Active → PastDue` when a renewal charge fails (enters dunning, billing-runs.md).
- `PastDue → Active` on successful retry; `PastDue → Cancelled/Expired` after dunning exhausts.
- `Active → Paused → Active` (optional hold, no billing while paused).
- `Active → Cancelled`: immediate or at period end (`CancelAtPeriodEnd`).

## Changes
- **Upgrade/downgrade:** switch plan with **proration** — credit the unused portion of the
  current plan and charge the prorated new plan (compute from days remaining in the period).
- **Pause/resume:** extends the period by the paused duration.

## Rules
- Entitlements follow status: a PastDue/Paused subscription may keep or lose access per policy.
- Every change raises an event and is audited; customer notified (15).

## API surface
- Subscribe; change plan (prorate); pause/resume; cancel (now / at period end); get status.
