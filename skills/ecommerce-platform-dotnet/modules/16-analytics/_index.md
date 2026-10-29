# Module 16 · Analytics & reporting — index

Operational insight for store owners. Financial statements live in accounting (06);
this module is commercial/behavioral analytics.

## Scope
- Admin dashboards.
- Sales/product/customer reports.
- Conversion funnel & event tracking.
- Exports and external analytics integration.

## Sub-files
- `dashboards.md`, `reports.md`, `funnel-events.md`, `exports-integrations.md`.

## Integration events
- Consumes most domain events (orders, payments, carts, stock, customers) to build metrics.

## Definition of done
- Dashboard + core reports return correct, tenant-scoped numbers; funnel reflects real
  events; exports work; no report leaks another tenant's data (tested).

## ASVS focus
- V4 (tenant/vendor-scoped data), V8 (consent for behavioral tracking).
