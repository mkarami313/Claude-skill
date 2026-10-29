# 07 · Suppliers

## Model
- `Supplier`: `Id`, `TenantId`, `Name`, legal/tax identifiers, contacts, addresses,
  payment terms (net days), default currency, active flag, rating/notes.
- `SupplierProduct` (optional catalog): which variants a supplier provides, supplier SKU,
  last purchase cost, lead time, min order qty.

## Rules
- Tenant-scoped; managing suppliers is permissioned (purchasing role).
- Payment terms drive AP due dates (06).
- Lead time + min order qty feed reorder suggestions.

## API surface
- CRUD suppliers; manage supplier-product catalog; supplier purchase history & balance (AP).
