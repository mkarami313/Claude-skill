# 06 · Accounts receivable & payable

Subledgers that track who owes the store and whom the store owes, reconciling to control
accounts in the GL.

## Accounts receivable (AR) — customers owe
- Driven by credit sales (B2B module 19, or unpaid official invoices).
- `ReceivableEntry` per customer: invoice charges (+), payments/credits (−), balance, due date.
- Aging buckets (current, 30/60/90+). Dunning reminders via notifications (15).
- Settles when payment (05) is applied; posts Dr Bank, Cr AR.

## Accounts payable (AP) — store owes
- Driven by goods receipts / supplier invoices (purchasing, module 07) and vendor
  settlements (marketplace, module 13).
- `PayableEntry` per supplier/vendor: invoice charges (+), payments (−), balance, due date.
- Scheduling: list due payables; record supplier payment → posts Dr AP, Cr Bank;
  publishes `SupplierPaymentMade`.

## Rules
- Subledger balances must equal their GL control account balances (reconciliation report).
- Multi-currency AR/AP tracked with FX revaluation at period end.
- Permissioned; audited.

## API surface
- Customer/supplier statements, aging reports, apply payment, schedule payable.
