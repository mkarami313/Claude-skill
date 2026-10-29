# 22 · Issuing gift cards

## Model
- `GiftCard`: `Id`, `TenantId`, `CodeHash` (never store plaintext), `InitialValue` (Money),
  `Balance` (Money, derived from ledger), `Status` (Active | Redeemed | Expired | Voided),
  `ExpiresOn`, `IssuedToEmail/Phone` (optional), `PurchasedByCustomerId` (optional).
- A gift-card **product** in the catalog (02) represents a buyable denomination.

## Issuing
- On `OrderPaid` for a gift-card product → generate a code with `RandomNumberGenerator`
  (long, unambiguous alphabet), store only its hash, set initial value and expiry.
- Deliver the plaintext code once via the chosen channel (15: email/SMS); show it to the
  buyer once. Never log or re-display the full code.
- Optional custom amount (within min/max) and scheduled delivery date / gift message.

## Rules
- Codes unique per tenant; collision-checked on generation.
- Issuance creates an accounting liability (06) — the store owes goods against it.

## API surface
- Issue gift card (internal, from order); resend delivery; look up by code (returns masked).
