# 09 · CRM & segmentation

## Customer 360
- Aggregate per customer: order count, total spent, average basket, last order date,
  lifetime value (LTV), returns rate, channels used.
- Interaction log: tickets, campaigns received, reviews.
- Staff tags and notes.

## Segmentation
- `Segment`: rule-based definition (e.g. "spent > X in 90 days", "no order in 180 days",
  "first purchase") evaluated by a background job.
- Standard segments: new, loyal, at-risk, inactive, high-value.
- `CustomerSegmentChanged` published when membership changes → feeds marketing (10).

## Rules
- All CRM data tenant-scoped; staff access permissioned.
- Segment computation is a scheduled job (20); heavy queries cached.
- Respect marketing consent when segments feed campaigns.

## API surface
- Customer 360 view; define/evaluate segments; list customers in a segment; tag/note.
