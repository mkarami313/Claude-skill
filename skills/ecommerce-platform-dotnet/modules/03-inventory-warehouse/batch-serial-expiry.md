# 03 · Batch/lot, expiry & serials

Optional per product; enable only for goods that need traceability (food, cosmetics, pharma,
electronics with warranties).

## Batch / lot tracking
- `Batch`: `Id`, `VariantId`, `LotNumber`, `ManufacturedOn`, `ExpiresOn`, received cost.
- Movements reference a `BatchId`; on-hand is tracked per batch.
- **Picking policy:** FEFO (first-expiry-first-out) for perishables, else FIFO.
- Expiry alerts: background job flags near-expiry/expired stock → `LowStockReached`-style
  alert and blocks selling expired stock.

## Serial numbers
- `SerialNumber`: unique per unit for serialized products; state (in-stock, sold, returned).
- Captured at receipt and at sale/shipment; enables warranty and RMA (04) traceability.

## Rules
- A product flagged batch/serial-tracked requires batch/serial on every inbound and outbound
  movement; reject movements missing them.
- Enforce no sale of expired batches; honor FEFO in allocation.

## API surface
- Register batch/serials at receipt; query stock by batch/expiry; serial lookup/history;
  near-expiry report.
