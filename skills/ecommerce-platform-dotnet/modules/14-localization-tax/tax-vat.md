# 14 · Tax / VAT

The tax engine. Ordering (04) calls it at checkout; accounting (06) posts the result.

## Model
- `TaxClass`: assigned to products (e.g. standard, exempt, reduced).
- `TaxRate`: `TaxClass` + region (country/province/city) → rate (%), effective dates.
- `TaxSettings` per tenant: prices entered inclusive or exclusive, rounding, display mode,
  VAT registration number.

## Computation
- Resolve the applicable rate from the buyer's region + product's tax class.
- Compute per line, then total; handle inclusive vs exclusive pricing correctly.
- Apply duties/extra levies where configured.
- Produce a tax breakdown for the order snapshot and invoice (04).

## Rules
- Server-authoritative; tax is part of the checkout total (never client-sent).
- Rates are date-effective (historical orders keep the rate used).
- Regional selling/shipping restrictions can block certain goods to certain regions.
- `TaxConfigChanged` published on rate/class edits.

## API surface
- CRUD tax classes/rates/settings; compute tax for a cart/address; VAT number validation.

## Links: output/input VAT reporting lives in accounting (06) reports.
