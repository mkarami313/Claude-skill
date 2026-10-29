# Module 08 · Shipping & logistics — index

Pluggable shipping methods with server-computed cost and fulfillment tracking.

## Scope
- Shipping method adapters (post, courier, pickup, digital).
- Zones and rate strategies; free-shipping rules.
- Fulfillment, label/tracking, delivery slots.

## Sub-files
- `methods-adapters.md`, `zones-rates.md`, `fulfillment-tracking.md`.

## Integration events
- Consumes `OrderPaid` to enable fulfillment; publishes `ShipmentDispatched`,
  `ShipmentDelivered` (feeds order lifecycle 04 and notifications 15).

## Definition of done
- Available methods + costs are computed server-side per destination/zone; a shipment can be
  created with tracking; status flows back to the order.

## ASVS focus
- V5 (address validation), V9/SSRF (carrier APIs allow-listed).
