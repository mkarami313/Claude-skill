# Module 06 · Accounting & finance — index

Keeps the books: a double-entry ledger that records the financial effect of commerce events,
plus receivables/payables, tax, reports, and export to external accounting software.

## Build-vs-integrate (read first)
- A full statutory GL is heavy. Recommended pragmatic path: keep an **internal double-entry
  ledger** for correctness and reporting, and **export** to the tenant's accounting software
  (e.g. Sepidar, Hesabfa, Holoo) for official filing. Both are covered here; a tenant can use
  internal-only, export-only, or both.

## Scope
- Chart of accounts (per tenant).
- Double-entry journal/ledger posted automatically from events.
- Accounts receivable (customers) and payable (suppliers).
- Tax/VAT accounting (computation lives in module 14; posting here).
- Financial reports (trial balance, P&L, balance sheet) and period close.
- Export/integration to external accounting systems.

## Sub-files
- `chart-of-accounts.md`, `journal-ledger.md`, `ar-ap.md`,
  `reports.md`, `period-close-export.md`.

## Integration events (consumed → journals posted)
- `OrderPaid`/`InvoiceIssued` → sales + VAT; `OrderShipped` → COGS + inventory (03 valuation);
  `PaymentRefunded`/`ReturnRefunded` → reversals; `GoodsReceiptPosted` (07) → inventory + AP;
  `SupplierPaymentMade` (07) → AP settlement; wallet (05) → customer-credit liability;
  marketplace `SettlementPaid` (13) → vendor payable.

## Definition of done
- Every financial event posts a balanced journal (debits = credits), tenant-scoped;
  trial balance balances; reports reconcile to orders/payments; export file validates.

## ASVS focus
- V4 (tenant isolation of books), V11 (balanced postings), V8 (immutable audit).
