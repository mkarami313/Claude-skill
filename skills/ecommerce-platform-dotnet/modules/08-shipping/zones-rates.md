# 08 · Zones & rates

## Model
- `ShippingZone`: `Id`, `TenantId`, name, matching rules (country/province/city or postal
  ranges). A destination resolves to the most specific matching zone.
- `ShippingRate`: `MethodId` + `ZoneId` → strategy and parameters.

## Rate strategies
- Flat per zone.
- By weight (tiers or per-kg) using parcel weight.
- By cart total (price brackets).
- By distance (needs geocoding; allow-listed service).
- Carrier-quoted (from the adapter's live API).

## Free shipping
- Rules: above a cart threshold, specific zones, specific products/categories, or via a
  coupon (module 10). Highest-priority matching rule wins.

## Rules
- Compute at checkout preview and again at order placement (server-authoritative).
- If no method serves the destination, block checkout for that address with a clear message.

## API surface
- CRUD zones & rates; test a rate for a sample destination/cart.
