# 03 · Stocktaking, adjustments & transfers

## Stocktaking / cycle counts
- `StockCount`: a counting session over a warehouse (full) or a subset (cycle count).
- Workflow: open → record counted quantities per variant/location → system computes
  variance vs ledger on-hand → review → **approve** → post adjustment movements for variances.
- Supports scanning (barcode) input; count lines reference location for accuracy.
- Freeze or snapshot on-hand at session start so ongoing operations don't corrupt variance.

## Adjustments
- `StockAdjustment`: manual correction with a mandatory `Reason` (damage, loss, found,
  correction) and approval for large deltas; posts a signed movement; audit-logged.

## Transfers
- `StockTransfer`: move quantity from warehouse A to B.
- Workflow: create → dispatch (transfer-out movement at A, goods in transit) →
  receive (transfer-in movement at B). Handles partial receipt and discrepancies.
- Publishes `StockTransferred`.

## Rules
- All of the above post through the ledger (never edit balances directly).
- Adjustments/count approvals are permissioned (role) and fully audited.
- Valuation (see valuation.md) is updated on every posting.

## API surface
- Open/record/approve count; create/approve adjustment; create/dispatch/receive transfer;
  variance report.
