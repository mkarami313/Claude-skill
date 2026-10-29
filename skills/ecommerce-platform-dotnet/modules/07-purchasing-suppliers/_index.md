# Module 07 · Purchasing & suppliers — index

How stock gets into the warehouse and how the store pays for it. Closes the loop between
inventory (03) and accounting (06).

## Scope
- Supplier records and terms.
- Purchase orders (PO) to suppliers.
- Goods receipt (GRN) → posts inbound stock + cost.
- Supplier invoices & payments (AP).

## Sub-files
- `suppliers.md`, `purchase-orders.md`, `goods-receipt.md`, `supplier-payments.md`.

## Integration events
- Publishes `PurchaseOrderApproved`, `GoodsReceiptPosted`, `SupplierPaymentMade`.
- Consumes `LowStockReached` (03) to suggest reorders.

## Definition of done
- A PO can be created, approved, partially received, and paid; receipt posts inbound stock
  movements with unit cost (feeds valuation 03) and an AP entry (06); reorder suggestions
  come from low-stock signals.

## ASVS focus
- V4 (supplier data scoping + approval permissions), V11 (receipt/cost correctness).
