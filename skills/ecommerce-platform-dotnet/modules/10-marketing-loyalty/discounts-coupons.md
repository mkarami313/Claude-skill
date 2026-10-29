# 10 · Discounts & coupons

## Model
- `Coupon`: `Code`, `TenantId`, type (Percent | FixedAmount | FreeShipping), value,
  scope (cart | product | category | brand), constraints, validity window, active flag.
- Constraints: min basket, max discount cap, total usage limit, per-customer limit,
  first-order-only, allowed customer segment, stacking policy.
- `CouponRedemption`: records each use (customer, order, amount) for limit enforcement.

## Rules (all server-side at checkout)
- Validate code exists, active, in window, scope matches cart, all limits respected.
- Compute the discount from server prices; cap by max discount.
- Enforce stacking policy (usually one coupon per order).
- Record redemption transactionally with order creation to prevent limit bypass under
  concurrency; rate-limit coupon tries (anti-brute-force).

## API surface
- CRUD coupons; validate/apply coupon to a cart; redemption report.
