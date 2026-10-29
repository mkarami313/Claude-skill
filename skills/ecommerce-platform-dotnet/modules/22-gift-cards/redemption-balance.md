# 22 · Redemption & balance

## Ledger
- `GiftCardTransaction` (append-only): `Amount` (signed), `Type` (Issue | Redeem | Refund |
  Void | Adjust), `ReferenceType`+`ReferenceId` (order), timestamp. `Balance` = Σ ledger.

## Redemption at checkout
- Applied as a payment method (05) or a checkout step (04): the buyer enters a code.
- Verify by hash; check Active + not expired + balance > 0.
- Deduct the lesser of balance and order total **atomically** (row lock / optimistic
  concurrency) so a code can't be double-spent under concurrent requests; remainder stays
  on the card, any shortfall is paid by another method.
- Publish `GiftCardRedeemed`; reduce the accounting liability (06) and recognize revenue.

## Rules
- **Rate-limit and lock** code-entry attempts per IP/customer — gift-card codes are a brute-
  force target (treat like a secret).
- Refund to a gift card re-credits via a `Refund` ledger entry.
- Expiry job marks expired cards and adjusts liability per policy/law.

## Tests
- Concurrent redemption of the last balance: exactly one succeeds. Expired/void code rejected.
- Partial redemption leaves correct remaining balance.

## API surface
- Check balance (by code, rate-limited); redeem (internal, from checkout); void; adjust (staff).
