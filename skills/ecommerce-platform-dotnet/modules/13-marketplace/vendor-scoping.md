# 13 · Vendor scoping (the vendor panel)

Vendors use the same APIs as the store, scoped so each sees only its own data.

## Scoping model
- Products, stock, orders carry a `VendorId` (in addition to `TenantId`).
- Vendor-role requests are filtered by `VendorId` the same way tenant filtering works
  (an additional global filter / mandatory predicate).
- A vendor can only read/modify its own catalog items, its lines of an order, and its stock.

## Order splitting
- An order containing items from multiple vendors is split into per-vendor sub-orders /
  fulfillment groups; each vendor sees and fulfills only its portion.
- Platform sees the whole order; customer sees one order with multiple shipments (08).

## Rules
- Per-object authz enforced in handlers, not only by filter (defense in depth) — test that a
  vendor cannot access another vendor's order/product by id.
- Vendor staff roles limited to vendor-scoped permissions.

## API surface
- Vendor catalog CRUD (own), vendor order list/fulfill (own portion), vendor stock, vendor
  reports — all auto-scoped.
