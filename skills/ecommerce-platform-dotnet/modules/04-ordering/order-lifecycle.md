# 04 · Order lifecycle (OMS)

## `Order` aggregate
- `Id`, `TenantId`, `CustomerId`, `OrderNumber` (human-readable, per-tenant sequence),
  `Currency`, line snapshots, totals breakdown (subtotal, discount, shipping, tax, grand
  total), addresses, chosen shipping + payment method, `Status`, timestamps, internal notes.
- `OrderLine` snapshot: product/variant id, name, unit price, qty, tax, discount — frozen.

## State machine (enforce legal transitions)
`PendingPayment → Paid → Processing → Shipped → Delivered`
plus `Cancelled` (from Pending/Paid/Processing) and `Refunded`/`Returned` (post-delivery).
- Each transition is a domain method that validates the source state and raises an event.
- Illegal transitions throw/return failure; never set status by free assignment.

## Operator actions (back-office, permissioned)
- Edit order before shipment (qty/address) → recompute + re-reserve.
- Partial/additional payment; manual mark-paid (bank receipt / card-to-card) with audit.
- Phone order creation on behalf of a customer.
- Cancel (release stock), refund (→ 05), add internal note.

## Rules
- Only the owning customer (or authorized staff) can view/modify an order (per-object authz).
- Every change is audit-logged with actor + timestamp.
- `OrderPaid` triggers fulfillment prep, accounting (06), notifications (15), analytics (16).

## API surface
- Place (checkout), get my orders / order detail, cancel, request return;
  staff: list/filter, transition status, edit, refund, note.
