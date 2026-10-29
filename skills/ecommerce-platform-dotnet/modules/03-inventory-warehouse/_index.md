# Module 03 · Inventory & warehouse (IMS) — index

A full warehouse/inventory system, not just a stock number. Stock is a **ledger**: every
change is a recorded movement, so on-hand is always explainable and auditable.

## Scope
- Multiple warehouses and internal locations (zones/bins).
- Stock as an immutable movement ledger; on-hand derived from it.
- Reservations/allocation tied to orders (04) to prevent overselling.
- Transfers between warehouses.
- Stocktaking / cycle counts and adjustments with variance.
- Batch/lot & expiry and serial-number tracking.
- Inventory valuation (FIFO or weighted average) for accounting (06).

## Sub-files
- `warehouses-locations.md` — warehouse & location model.
- `stock-ledger-movements.md` — movement types, on-hand derivation.
- `reservations-allocation.md` — reserve/release, overselling prevention.
- `stocktaking-adjustments.md` — counts, adjustments, transfers.
- `batch-serial-expiry.md` — lots, expiry, serials.
- `valuation.md` — costing method & valuation feed to accounting.

## Integration events
- Publishes `StockReserved`, `StockReleased`, `StockAdjusted`, `StockTransferred`,
  `LowStockReached`, `GoodsReceiptPosted` (from 07 receipts).
- Consumes `OrderPlaced`/`OrderPaid`/`OrderCancelled` (04) and `GoodsReceived` (07).

## Definition of done
- On-hand equals the sum of ledger movements at all times; stock cannot go negative under
  concurrent orders (tested); transfers, counts, batches, and valuation all post to the ledger.

## ASVS focus
- V11 (concurrency & business rules), V4 (tenant/warehouse scoping).
