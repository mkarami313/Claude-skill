# 23 · Billing runs, dunning & retries

The recurring charge engine. Correctness and idempotency are everything here.

## Model
- `BillingCycle`: `SubscriptionId`, period start/end, amount, `Status`
  (Pending | Paid | Failed | Skipped), attempt count, generated order/invoice id.

## Renewal run (scheduled job, module 20)
1. A recurring Hangfire job finds subscriptions whose `CurrentPeriodEnd` is due.
2. For each, create a `BillingCycle` and an order (04) for the plan amount, **idempotent per
   (subscription, period)** so a re-run never double-bills.
3. Charge the stored payment mandate (05, server-to-server / off-session).
4. On success → mark Paid, advance the period, publish `SubscriptionRenewed`, post revenue (06).
5. On failure → mark Failed, move subscription to `PastDue`, start dunning.

## Dunning (failed-payment recovery)
- Retry schedule with backoff (e.g. day 1, 3, 5, 7); each retry is a new attempt on the same
  cycle, still idempotent.
- Notify the customer each attempt (15) with a link to update payment.
- After the final retry fails → cancel/expire the subscription per policy.

## Rules
- Off-session charges require a stored mandate/agreement (many Iranian gateways need the
  customer present each time — if so, send a pay link instead of an off-session charge and
  only renew on their return). Capture this per gateway in payments (05).
- Every charge attempt is logged and reconciled; no double-charge under job re-runs.

## API surface
- Trigger billing run (job); retry a failed cycle; preview next charge; dunning status.
