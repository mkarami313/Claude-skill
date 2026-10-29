# 07 · Purchase orders (PO)

## Model
- `PurchaseOrder`: `Id`, `TenantId`, `SupplierId`, `WarehouseId` (destination), `Currency`,
  lines, totals, `Status`, expected date, notes.
- `PurchaseOrderLine`: `VariantId`, ordered qty, unit cost, tax, received qty (running).

## Workflow / states
`Draft → Approved → PartiallyReceived → Received → Closed` (+ `Cancelled`).
- Approval is permissioned (threshold-based: large POs need higher approval).
- `Approved` publishes `PurchaseOrderApproved`.

## Reorder suggestions
- A background job (or `LowStockReached` handler) proposes draft POs for variants at/below
  reorder point, grouped by preferred supplier, using lead time + reorder qty.

## Rules
- Costs here are the source of inventory unit cost (03 valuation).
- Can't receive more than ordered per line (unless over-receipt tolerance configured).
- Tenant-scoped; audited.

## API surface
- CRUD/approve/cancel PO; generate suggested POs; get PO status & receipts.
