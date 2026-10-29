# 13 · Vendor ratings & shared listings

## Vendor ratings
- Buyers rate the vendor (not just the product) after delivery; aggregate score per vendor.
- Performance metrics: on-time dispatch rate, cancellation rate, response time, return rate.
- Low performance can trigger review/suspension (permissioned, audited).

## Shared listings & buy-box
- When several vendors sell the same catalog product, each has its own offer
  (`VendorOffer`: price, stock, condition, handling time).
- **Buy-box** selects the default offer by a deterministic rule (price + availability +
  vendor rating + handling time); others shown as "other sellers".
- Add-to-cart targets a specific `VendorOffer`.

## Rules
- Ratings tied to verified purchases; moderated (09 review rules apply).
- Buy-box rule configurable per tenant; recomputed on offer changes.

## API surface
- Submit vendor rating; vendor scorecard; manage offers; get buy-box + other sellers.
