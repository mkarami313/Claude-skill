# 07 · Goods receipt (GRN)

## Model
- `GoodsReceipt`: `Id`, `TenantId`, `PurchaseOrderId`, `WarehouseId`, received date, lines,
  received-by.
- `GoodsReceiptLine`: `VariantId`, received qty, unit cost, optional batch/serial +
  expiry (if the product is batch/serial-tracked, module 03), destination location.

## Workflow
1. Receive against a PO (full or partial).
2. For each line: post an **inbound stock movement** (03) with the unit cost → updates
   on-hand and valuation; register batches/serials if required.
3. Record discrepancies (short/over/damaged) with reasons.
4. Publish `GoodsReceiptPosted` → accounting (06) posts Dr Inventory, Cr AP.
5. Update the PO line received qty and status.

## Rules
- Receipt and stock posting happen transactionally and idempotently.
- Damaged goods go to a quarantine location, not sellable stock.
- Over-receipt only within configured tolerance.

## API surface
- Create receipt against PO (full/partial); record discrepancies; get receipts by PO.
