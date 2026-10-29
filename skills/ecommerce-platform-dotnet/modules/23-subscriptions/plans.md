# 23 · Subscription plans

## Model
- `SubscriptionPlan`: `Id`, `TenantId`, `Name`, linked catalog product, `Price` (Money),
  `Interval` (Day | Week | Month | Year) + `IntervalCount` (e.g. every 3 months),
  `TrialDays`, `Status` (Active | Archived), granted features/entitlements.
- Optional usage-based or tiered pricing add-ons (metered billing) as an extension.

## Rules
- Price and interval are server-authoritative; changing a plan's price doesn't retroactively
  change existing subscriptions unless a migration is explicitly run.
- Entitlements (what the subscription unlocks) are checked by the relevant modules via a
  contract query (e.g. "is customer X entitled to feature Y").
- Archiving a plan stops new subscriptions but keeps existing ones running.

## API surface
- CRUD plans; list active plans (storefront); get plan entitlements.
