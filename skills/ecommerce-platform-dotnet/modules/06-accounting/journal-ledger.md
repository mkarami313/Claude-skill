# 06 · Journal & ledger (double-entry)

## Model
- `JournalEntry`: `Id`, `TenantId`, `Date`, `Description`, `SourceType`+`SourceId`
  (the event/document), `Status` (Draft | Posted | Reversed), `CreatedBy`.
- `JournalLine`: `AccountId`, `Debit`, `Credit` (one is zero), optional subledger ref
  (customer/supplier/vendor). **Σ Debit must equal Σ Credit** or the entry is rejected.

## Automatic posting (event handlers, idempotent)
- `OrderPaid`/`InvoiceIssued`: Dr Bank/Gateway-Receivable, Cr Sales, Cr VAT Payable,
  Dr Discounts (if any).
- `OrderShipped`: Dr COGS, Cr Inventory (amount from valuation, module 03).
- `PaymentRefunded`/`ReturnRefunded`: reverse the sale/VAT; restock reverses COGS.
- `GoodsReceiptPosted` (07): Dr Inventory, Cr Accounts Payable.
- `SupplierPaymentMade` (07): Dr Accounts Payable, Cr Bank.
- Wallet top-up/use (05): adjust Customer-Credit liability.
- Payment fees: Dr Payment Fees, Cr Bank/Gateway.

## Rules
- Each event posts exactly once (idempotency key = SourceType+SourceId).
- Posted entries are immutable; corrections are **reversing entries**, never edits.
- All postings tenant-scoped; subledgers (AR/AP) reconcile to control accounts.

## API surface
- Post manual journal (permissioned), reverse entry, query ledger by account/date,
  account balance as-of date.
