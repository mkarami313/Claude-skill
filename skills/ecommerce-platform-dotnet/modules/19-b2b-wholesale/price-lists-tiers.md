# 19 · Price lists & quantity tiers

## Model
- `PriceList`: named list assignable to organizations or customer groups; per-variant
  prices or a percentage off base; currency; validity window.
- `QuantityTier`: per product/variant price breaks (e.g. 10+ → X, 100+ → Y).
- `CustomerGroup`: groups of customers/orgs sharing a price list.

## Resolution
- Effective price = most specific applicable (org/customer price list → group → quantity
  tier → base price). Computed server-side at cart/checkout.
- MOQ (minimum order quantity) and order multiples enforced for wholesale items.

## Rules
- Prices server-authoritative; never trust client wholesale prices.
- Overlapping lists resolved by a defined priority; validity windows respected.

## API surface
- CRUD price lists & tiers; assign to org/group; resolve price for a buyer+variant+qty.
