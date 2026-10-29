# 14 · Multi-store on one core

Several storefronts/brands managed under one tenant, sharing or separating data as needed.

## Model
- `Store`: belongs to a tenant; has its own domain(s), brand/theme config, default
  locale & currency, and a catalog scope (shared catalog or a store-specific subset).
- `StorePriceList` (optional): store-specific pricing over the shared catalog.

## Scoping
- A request resolves to a store (via domain) within the tenant; catalog/price/content can be
  filtered to that store while inventory and back-office may be shared.
- Clear rules for what is shared (stock, customers, orders) vs store-specific (branding,
  price list, content, enabled payment/shipping).

## Rules
- Reuse tenant isolation; store scope is an additional filter, not a new tenant.
- Keep it optional — most tenants use a single store.

## API surface
- CRUD stores; assign domains; store catalog/price scope; store config.
