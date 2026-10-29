# 10 · Campaigns & automation

## Campaigns (one-off, targeted)
- `Campaign`: channel (SMS | email | push), target segment (09), message template,
  schedule, status; delivery via notifications module (15) as background jobs.
- Track sent/delivered/opened/clicked and attributed orders.

## Lifecycle automation (triggered flows)
- Event-driven flows, each a subscriber + delayed job:
  - **Welcome** on `CustomerRegistered`.
  - **Abandoned cart** on `CartAbandoned` (optionally with a time-boxed coupon).
  - **Win-back** when a customer enters the "inactive" segment.
  - **Post-purchase** (review request, cross-sell) after `OrderDelivered`.
  - **Birthday / anniversary** on date triggers.
- Each flow has conditions, delays, and frequency caps to avoid spamming.

## Rules
- Respect marketing consent and quiet hours; honor unsubscribe.
- Deduplicate and cap messages per customer per period.
- All sends tenant-scoped and permissioned; no PII/secret in logs.

## API surface
- Create/schedule campaign; define automation flow; metrics per campaign/flow;
  manage consent/unsubscribe.
