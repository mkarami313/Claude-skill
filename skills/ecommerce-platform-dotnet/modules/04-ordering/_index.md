# Module 04 · Ordering (cart, checkout, OMS) — index

Turns a cart into a paid, fulfilled order. Everything financial is recomputed server-side.

## Scope
- Cart (guest + user, merge on login, abandoned-cart detection).
- Checkout that recomputes prices, discounts, shipping, tax, and total.
- Order lifecycle (state machine) and operator actions.
- Returns / RMA.
- Invoicing with an immutable price snapshot.

## Sub-files
- `cart.md` — cart model and rules.
- `checkout.md` — server-authoritative checkout pipeline.
- `order-lifecycle.md` — order aggregate, states, operator actions.
- `returns-rma.md` — returns workflow.
- `invoicing.md` — invoice generation & snapshot.

## Integration events
- Publishes `CartAbandoned`, `OrderPlaced`, `OrderPaid`, `OrderCancelled`, `OrderShipped`,
  `OrderDelivered`, `ReturnApproved`, `ReturnRefunded`.
- Consumes `PaymentVerified`/`PaymentFailed` (05), pulls prices (02), discounts (10),
  shipping (08), tax (14), reservations (03).

## Definition of done
- Checkout rejects tampered totals (tested); order states follow legal transitions only;
  stock reserved/released correctly; invoice snapshot immutable.

## ASVS focus
- V11 (business logic, anti-tamper, anti-automation), V4 (owner/tenant-only order access).
