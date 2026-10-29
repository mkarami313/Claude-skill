# 08 · Fulfillment & tracking

## Model
- `Shipment`: `Id`, `TenantId`, `OrderId`, `WarehouseId`, `MethodId`, lines + quantities,
  `TrackingNumber`, `Carrier`, `Status` (Pending | Dispatched | InTransit | Delivered |
  Failed | Returned), timestamps.
- Supports split shipments (multiple warehouses/partial fulfillment).

## Workflow
1. On `OrderPaid`, create a pending shipment (or wait for staff pick).
2. Pick/pack → create shipment: commit stock outbound movement (03), generate tracking +
   label/packing slip.
3. Dispatch → publish `ShipmentDispatched` → order `Shipped`, notify customer (15).
4. Delivery confirmation (manual, carrier webhook, or customer) → `ShipmentDelivered` →
   order `Delivered`.

## Delivery slots
- Optional day/time slots for bulky/perishable goods; capacity per slot; chosen at checkout.

## Rules
- Tracking info exposed to the order owner; carrier webhooks verified (signature) + SSRF-safe.
- Packing slip excludes prices if configured; labels generated via a service/PDF tooling.

## API surface
- Create/dispatch shipment; update status; customer tracking lookup; print label/slip.
