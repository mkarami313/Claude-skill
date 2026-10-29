# 21 · Fraud detection & forecasting

## Fraud / risk scoring
- Score orders/payments for risk using signals: velocity (orders/IP/device), mismatched
  address, unusual amount, failed-payment patterns, new account + high value.
- `RiskScore` on an order → actions: allow, review (hold for staff), or challenge.
- Feeds checkout (04) and payments (05); works with rate limiting (20) and anti-automation.

## Demand forecasting
- Predict demand per product from sales history + seasonality → better reorder points (03)
  and purchasing suggestions (07); flag likely stockouts.

## Approach
- Models run as background jobs (20) over historical data; expose scores/forecasts via APIs.
- Start with simple heuristics/statistics; upgrade to ML where it pays off.

## Rules
- Risk decisions are explainable and overridable by staff (avoid silent false declines).
- Tenant-scoped data and models; privacy-respecting; audited.

## API surface
- Get order risk score; review queue; demand forecast per product; reorder suggestions feed.
