# Module 10 · Marketing & loyalty — index

Tools that actively grow sales and retention. Every limit is enforced server-side.

## Scope
- Discounts & coupons; automatic promotions.
- Loyalty points & tiers.
- Referral & affiliate.
- Campaigns & lifecycle automation.

## Sub-files
- `discounts-coupons.md`, `promotions.md`, `loyalty-tiers.md`,
  `referral-affiliate.md`, `campaigns-automation.md`.

## Integration events
- Consumes `CartAbandoned`, `OrderPaid`, `CustomerRegistered`, `CustomerSegmentChanged`.
- Publishes `CouponIssued`, `PointsEarned`, `RewardGranted`.

## Definition of done
- Coupons obey all limits and can't be abused (tested); promotions apply correctly at
  checkout; loyalty points accrue/redeem; automations fire from the right events;
  affiliate attribution recorded.

## ASVS focus
- V11 (promo abuse / anti-automation), V5 (coupon input validation).
