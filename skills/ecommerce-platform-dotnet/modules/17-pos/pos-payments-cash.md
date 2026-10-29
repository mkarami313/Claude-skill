# 17 · POS payments & receipts

## Payment methods
- Cash (with change calculation), card via a physical POS terminal (manual/confirmed or
  integrated), wallet (05), and split payments across methods.
- Card-present terminal integration is optional; otherwise record an externally-approved
  card payment with reference.

## Receipts
- Print a receipt (thermal) and/or send via SMS/email (15); include store/tax details.
- Official invoice (04) on request with VAT (14).

## Accounting
- Cash sales flow into the register session cash (see register-sessions); card/wallet post
  like online payments; all reconcile in accounting (06).

## Rules
- Amounts server-authoritative; splits must sum to the total.
- Every payment tied to the order and the register session for reconciliation.

## API surface
- Take payment (method, amount); split payment; compute change; print/send receipt.
