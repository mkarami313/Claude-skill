# Module 17 · Point of Sale (in-store) — index

In-store selling that shares the same catalog, stock, customers, and accounting as online.
Optional (feature flag).

## Scope
- Register/cashier sessions with cash control.
- Fast POS sales (barcode scan, quick checkout).
- POS payments (cash, card/POS terminal, wallet) and receipts.
- Offline resilience and sync.

## Sub-files
- `register-sessions.md`, `pos-sales.md`, `pos-payments-cash.md`, `offline-sync.md`.

## Integration events
- Reuses ordering/inventory/accounting events; publishes `RegisterSessionClosed`.

## Definition of done
- A cashier opens a session, scans items, takes payment, prints a receipt; stock and
  accounting update like an online order; cash is reconciled at close; offline sales sync.

## ASVS focus
- V4 (register/role scoping), V11 (cash reconciliation correctness).
