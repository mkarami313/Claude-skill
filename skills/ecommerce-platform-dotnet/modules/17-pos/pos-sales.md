# 17 · POS sales

## Flow
- Cashier scans/searches items → builds a cart (reuses ordering cart model, channel = POS).
- Fast add by barcode (variant lookup); quantity edit; line discounts (permissioned).
- Optional customer attach (phone lookup) for loyalty/history; else anonymous sale.
- Checkout computes totals server-side (prices, promotions 10, tax 14) like online.
- Creates an order (channel=POS) → reserves/commits stock at the store's warehouse (03)
  immediately (goods handed over now), marks paid on payment.

## Rules
- Stock decremented from the store location in real time; blocks sale if unavailable
  (unless override permitted).
- Returns/exchanges at POS reuse the returns flow (04) against the original order.
- Receipts generated (print/SMS/email); official invoice if requested (04).

## API surface
- Scan/add item; apply discount; attach customer; checkout; park/resume sale; return/exchange.
