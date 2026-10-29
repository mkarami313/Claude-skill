# 13 · Commission & settlement

## Commission
- `CommissionProfile`: rate per vendor or per category (percent, optional fixed fee,
  min/max). Resolved per order line.
- On `OrderPaid`: compute platform commission and vendor net per line; record a
  `VendorEarning` (gross, commission, fees, net) tied to the order.

## Settlement / payout
- `Settlement`: periodic (e.g. weekly) aggregation of a vendor's net earnings minus
  refunds/adjustments for the period → a statement + payable.
- Record payout (bank transfer reference) → publish `SettlementPaid` → accounting (06)
  posts vendor payable settlement.
- Handle returns/refunds (04) by reversing the related vendor earning.

## Rules
- Earnings confirmed only on paid orders; reversed on refund/return.
- Hold period before payout (configurable) to cover returns.
- All amounts tenant + vendor scoped; statements immutable once issued.

## API surface
- Vendor earnings report; generate settlement; record payout; platform commission report.
