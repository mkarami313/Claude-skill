# 16 · Dashboards

## Admin dashboard (at a glance)
- Today/week/month: revenue, orders, average order value, conversion rate.
- Open orders by status, orders needing action (unpaid, to ship, returns).
- Bestsellers, low-stock alerts (03), new vs returning customers.
- Trend sparklines vs previous period.

## Role-specific dashboards
- Warehouse: picking queue, low stock, incoming POs.
- Support: open tickets, SLA breaches.
- Vendor (13): own sales, payouts, ratings.

## Rules
- All widgets tenant- (and role/vendor-) scoped.
- Metrics precomputed/cached (Redis, 20); dashboard reads are cheap, not live heavy queries.
- Time zone and currency respect tenant settings (14).

## API surface
- Dashboard summary endpoint(s) per role; configurable widgets.
