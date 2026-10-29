# 08 · Shipping methods & adapters

## Abstraction
- `IShippingMethod` adapter: `GetQuote(destination, parcel) → cost + eta` and
  `CreateShipment(order) → trackingNumber + label`.
- Registered per key; tenant enables/configures which methods are active.

## Built-in methods
- **Post** (priority/registered), **courier/freight** (e.g. Tipax), **in-city bike courier**,
  **store pickup** (no cost), **digital** (no shipping for digital goods).
- Optional **carrier API** adapters for live rates/tracking (allow-listed, TLS, timeout).

## Rules
- The server selects the cost; the client only picks the method.
- A cart of only digital goods skips shipping entirely.
- Parcel weight/dimensions come from variant data (02) for weight-based quotes.

## API surface
- List available methods + quotes for a destination/cart; configure methods per tenant.
