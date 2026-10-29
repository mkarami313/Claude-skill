# Module 23 · Subscriptions & recurring billing — index

Recurring revenue: plans customers subscribe to, billed on a cycle, with renewals, dunning,
and cancellation. Builds on catalog's subscription product type (02), orders (04), and
payments (05). Optional (feature flag).

## Scope
- Subscription plans (price, interval, trial, features).
- Subscriber lifecycle (active, past-due, paused, cancelled).
- Recurring billing runs: renewals, proration, dunning, retries.

## Sub-files
- `plans.md` — plan model and pricing.
- `lifecycle.md` — subscription states and changes (upgrade/downgrade/pause/cancel).
- `billing-runs.md` — the recurring charge engine, dunning, retries.

## Integration events
- Publishes `SubscriptionStarted`, `SubscriptionRenewed`, `SubscriptionPastDue`,
  `SubscriptionCancelled`.
- Consumes `PaymentVerified`/`PaymentFailed` (05) for each billing attempt.

## Definition of done
- A customer subscribes (with optional trial); renewals generate orders + charge payment on
  schedule; failed charges enter dunning with retries; upgrade/downgrade prorates correctly;
  cancellation stops future billing. All idempotent and tenant-scoped.

## ASVS focus
- V11 (billing correctness, proration, no double-charge), V8 (recurring-payment mandates).
