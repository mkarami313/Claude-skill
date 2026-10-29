# Module 22 · Gift cards — index

Prepaid, transferable value that a buyer purchases and a (possibly different) person
redeems. Distinct from the wallet (05, tied to one customer) and coupons (10, a discount):
a gift card is a sold balance bearer instrument.

## Scope
- Issue gift cards (digital code; optional physical).
- Redeem at checkout (full/partial), with remaining balance.
- Balance ledger, expiry, and reissue/void.

## Sub-files
- `issuing.md` — purchase/issue, codes, delivery.
- `redemption-balance.md` — redeem, ledger, expiry.

## Integration events
- Publishes `GiftCardIssued`, `GiftCardRedeemed`, `GiftCardVoided`.
- Consumes `OrderPaid` (when a gift-card product is purchased → issue the card).

## Definition of done
- A purchased gift card issues a secure code; redemption deducts from balance atomically,
  can't go negative or be double-spent (tested); balance = ledger; liability posts to
  accounting (06).

## ASVS focus
- V2/V5 (code brute-force protection, rate limiting), V11 (atomic balance), V8 (code hashed).
