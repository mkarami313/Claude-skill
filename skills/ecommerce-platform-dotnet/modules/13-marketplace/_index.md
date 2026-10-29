# Module 13 · Marketplace / multi-vendor (optional) — index

Turns a single store into "many sellers on one site". Because the core is already
multi-tenant, this is mostly a **role + settlement** layer. Enabled per tenant (feature flag).

## Scope
- Vendor onboarding & verification.
- Vendor-scoped access to catalog/orders/stock.
- Commission & settlement/payouts.
- Vendor ratings & shared listings (buy-box).

## Sub-files
- `vendor-onboarding.md`, `vendor-scoping.md`, `commission-settlement.md`, `ratings.md`.

## Integration events
- Publishes `VendorApproved`, `SettlementPaid`.
- Consumes `OrderPaid` (split per vendor), `ReturnRefunded` (adjust settlement).

## Definition of done
- A vendor manages only its own catalog/orders (per-object authz tested); commission +
  settlement compute correctly and post to accounting (06); buy-box selection is deterministic.

## ASVS focus
- V4 (strict vendor scoping), V11 (commission/settlement correctness).
