# 07 · Supplier invoices & payments

## Model
- `SupplierInvoice`: `Id`, `TenantId`, `SupplierId`, optional `PurchaseOrderId`, number,
  date, lines, tax, total, due date (from supplier terms), status (Open | Paid | Partial).
- `SupplierPayment`: `Id`, `SupplierInvoiceId`/`SupplierId`, amount, method, date, reference.

## Workflow
- Match supplier invoice to PO + goods receipt (3-way match: PO ↔ receipt ↔ invoice);
  flag mismatches for review.
- Record payment (full/partial) → publishes `SupplierPaymentMade` → accounting (06) posts
  Dr AP, Cr Bank; updates AP balance and aging.

## Rules
- 3-way match discrepancies require approval before payment.
- Due dates feed the AP aging/scheduling report (06).
- Permissioned; audited; multi-currency aware.

## API surface
- Enter supplier invoice; run 3-way match; record payment; AP aging & due list.
