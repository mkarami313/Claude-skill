# 04 · Checkout (server-authoritative)

The single most security-sensitive flow. The server computes everything; the client only
chooses options.

## Pipeline (one transaction boundary at order creation)
1. Load cart; re-resolve each line's price from catalog (02) for the cart currency.
2. Validate shipping address + selected shipping method; compute shipping cost (08).
3. Apply discounts/coupons (10) with all their limits re-checked server-side.
4. Compute tax/VAT (14) per line and total.
5. Compute the **final total**. If the client sent an expected total, it must match exactly
   or the request is rejected.
6. Reserve stock (03) for every line; if any fails, abort and release.
7. Create `Order` in `PendingPayment` with a full line + price snapshot.
8. Hand off to payments (05) → return redirect URL.

## Rules
- Never accept client-sent prices, totals, discount amounts, or tax.
- Enforce business limits: max quantity per line, one-coupon rules, min order value.
- **Anti-automation:** rate-limit checkout and coupon application per user/IP; add a
  challenge on abuse (ASVS V11).
- Idempotent order creation keyed by cart + client idempotency key (no double orders).

## API surface
- Preview checkout (totals breakdown, no order); place order (creates order + payment intent).
