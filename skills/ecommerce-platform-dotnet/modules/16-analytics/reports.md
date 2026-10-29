# 16 · Reports

## Sales
- By period, product, category, brand, vendor (13), payment method, shipping method,
  channel (web/app/bot/POS), coupon/campaign.
- Metrics: revenue, units, AOV, discount impact, refund rate, net sales.

## Customers
- New vs returning, cohort retention, LTV distribution, churn, top customers, RFM.

## Products & inventory
- Best/worst sellers, stock turnover, dead stock, sell-through, margin by product
  (uses valuation/COGS from 03/06).

## Marketing
- Campaign/coupon performance, abandoned-cart recovery rate, affiliate performance.

## Rules
- Tenant/vendor-scoped; computed from events + read models; heavy ones as background jobs.
- Support date ranges, comparisons, and grouping; results cacheable.

## API surface
- Parameterized report endpoints (type + filters + grouping + range); saved reports.
