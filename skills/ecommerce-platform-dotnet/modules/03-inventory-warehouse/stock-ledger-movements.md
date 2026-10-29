# 03 · Stock ledger & movements

On-hand is never edited directly. You **post a movement**; balances are derived.

## `StockMovement` (append-only)
- `Id`, `TenantId`, `WarehouseId`, `VariantId`, optional `LocationId`/`BatchId`/`Serial`,
  `Quantity` (signed: + in, − out), `UnitCost` (for valuation), `Type`, `Reason`,
  `ReferenceType` + `ReferenceId` (order, PO, transfer, count), `OccurredAtUtc`, `UserId`.

## Movement types
- **Inbound:** goods receipt (from PO, module 07), customer return, transfer-in, count-up,
  initial load.
- **Outbound:** sale/shipment (order 04 / POS 17), damage/loss write-off, transfer-out,
  count-down.
- **Internal:** location move within a warehouse.

## Deriving balances
- `OnHand` per stock item = Σ movement quantities. Maintain the `StockItem` projection
  transactionally with each movement for fast reads; reconcile periodically.
- Every movement is idempotent per reference to avoid double-posting on retries.

## Rules
- Posting a movement and updating the projection happen in one DB transaction.
- Outbound that would drive `Available` below zero is rejected (unless backorder allowed
  for that product — see catalog type + reservations).
- Low stock: when `Available ≤ ReorderPoint`, publish `LowStockReached`.

## API surface
- Post movement (internal use cases call this); list ledger by variant/warehouse/date;
  get on-hand/available snapshot; reconcile projection job.
