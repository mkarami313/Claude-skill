# 03 · Warehouses & locations

## Model
- `Warehouse`: `Id`, `TenantId`, `Name`, `Code`, address, type (store | DC | dropship),
  active flag, priority (for fulfillment selection).
- `Location` (optional, within a warehouse): zone/aisle/shelf/bin, for pick accuracy.
- `StockItem`: the on-hand balance of a `VariantId` at a `WarehouseId` (and optionally
  `LocationId`) — **a projection** kept in sync with the movement ledger, plus:
  `OnHand`, `Reserved`, `Available = OnHand - Reserved`, `ReorderPoint`, `ReorderQty`.

## Rules
- A variant can exist in many warehouses; each has its own balances.
- `Available` is what the storefront shows and what orders consume.
- Warehouse/location scoped to tenant; staff access limited by role (HR 18) and warehouse.
- Fulfillment picks a warehouse by rule: nearest to destination, priority, or availability.

## API surface
- CRUD warehouses/locations; set reorder point/qty per stock item;
  query on-hand/available by variant across warehouses.
