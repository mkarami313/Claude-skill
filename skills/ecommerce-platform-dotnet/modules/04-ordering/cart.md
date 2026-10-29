# 04 · Cart

## Model
- `Cart`: `Id`, `TenantId`, optional `CustomerId`, `CartToken` (for guests), `Currency`,
  timestamps, status (active | converted | abandoned).
- `CartLine`: `VariantId`, `Quantity`, and a **display** unit price resolved server-side.

## Rules
- Guest cart keyed by `CartToken` (httpOnly cookie or header); user cart persisted.
- On login, **merge** guest cart into the user cart (sum quantities, cap by availability).
- Prices and availability are resolved server-side on every read and re-validated at
  checkout — the cart never dictates price.
- Quantity capped by `Available` (03) unless backorder allowed; show stock state per line.
- Support saved-for-later, wishlist, and compare lists (separate lightweight lists).

## Abandoned cart
- A cart with items and no activity for N minutes/hours → publish `CartAbandoned`
  (marketing 10 + notifications 15 send a reminder, optionally with a coupon).

## API surface
- Get cart; add/update/remove line; clear; merge on login; move to wishlist/saved.
