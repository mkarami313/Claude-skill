# 10 · Loyalty & tiers

## Points
- `LoyaltyAccount` per customer with a points balance, backed by an append-only
  `PointsEntry` ledger (earned, redeemed, expired, adjusted).
- Earn rules: points per amount spent or per action (review, referral, signup).
- Redeem: convert points → wallet credit (05) or order discount, at a configured rate.
- Expiry: points expire after N months; a job posts expiry entries.

## Tiers
- `Tier` (e.g. Bronze/Silver/Gold) with thresholds (spend or points over a period) and
  benefits (earn multiplier, free shipping, exclusive promos).
- Tier recalculated by a background job; changes notify the customer (15).

## Rules
- Points balance = Σ ledger; never negative; redeem checks balance transactionally.
- Earning on an order is confirmed on `OrderPaid`, reversed on refund/return.
- Loyalty liability feeds accounting (06).

## API surface
- Get balance/history; redeem points; tier status & benefits; configure rules/tiers.
