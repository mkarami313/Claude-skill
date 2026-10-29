# 10 · Automatic promotions

Discounts applied without a code, by rule, at the cart level.

## Model
- `Promotion`: `TenantId`, name, condition, effect, priority, validity window, active.
- Conditions: cart total ≥ X, quantity of product/category ≥ N, customer segment, time-based.
- Effects: percent/amount off, buy-X-get-Y (BOGO), tiered discount, bundle price,
  free gift, free shipping.

## Flash sales
- Time-boxed price overrides with start/end + countdown metadata for the storefront.
- The sale price is snapshotted into the order at purchase time.

## Rules
- Evaluate all active promotions at cart/checkout; apply by priority; define whether they
  stack with coupons.
- Server computes every effect; never trust client-applied promotions.
- Guard against unbounded stacking (cap total discount per order).

## API surface
- CRUD promotions; preview applicable promotions for a cart; schedule flash sales.
