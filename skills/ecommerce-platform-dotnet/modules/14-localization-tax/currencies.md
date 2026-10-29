# 14 · Currencies

## Model
- `Currency`: code (ISO 4217 or custom like IRR/IRT), symbol, minor-unit exponent, active.
- `ExchangeRate`: base → quote rate, effective timestamp, source (manual | provider).
- Money is always stored as **minor units (integer) + currency code** — never float.

## Rules
- Each tenant has a base currency; stores/markets may display/settle in others.
- Rates updated manually or by a scheduled job from an allow-listed provider →
  publish `ExchangeRatesUpdated`.
- Price rounding rules per currency (e.g. round to nearest 1000 IRR); apply consistently at
  display and checkout.
- Conversions use the effective rate at the relevant time; store the rate used on the order.
- Note IRR vs IRT (Toman) handling explicitly to avoid 10× errors.

## API surface
- CRUD currencies; update/list exchange rates; convert amount; rounding config.
