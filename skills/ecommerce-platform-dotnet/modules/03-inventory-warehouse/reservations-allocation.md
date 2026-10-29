# 03 · Reservations & allocation

Prevents overselling between "added to order" and "shipped".

## Flow
- On `OrderPlaced` (04): **reserve** the ordered quantity per variant at the chosen
  warehouse → increment `Reserved` (reduces `Available`, not `OnHand`).
- On `OrderShipped` / fulfillment: post an outbound movement (reduces `OnHand`) and release
  the reservation.
- On `OrderCancelled` or payment timeout: **release** the reservation (restore `Available`).
- Reservations have an expiry for unpaid orders; a background job releases expired ones.

## Concurrency (critical)
- Reserve inside a transaction using row locking (`SELECT ... FOR UPDATE`) or optimistic
  concurrency (rowversion) on the `StockItem`; reject if `Available < requested`.
- Make reserve/release idempotent keyed by order line id (safe under event retries).

## Backorder / pre-order
- If the product allows backorder/pre-order, permit reservation beyond `Available` and
  flag the line; fulfillment waits for incoming stock (links to purchasing 07).

## API surface
- Reserve(orderLine), Release(orderLine), Commit/ship(orderLine) — invoked by event
  handlers; query reservations by order/variant.

## Tests
- Concurrent orders for the last unit: exactly one succeeds; the other is rejected.
