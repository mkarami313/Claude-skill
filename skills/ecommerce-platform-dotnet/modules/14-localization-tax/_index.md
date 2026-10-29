# Module 14 · Localization, multi-store & tax — index

Makes a store speak any language/currency and bill tax correctly.

## Scope
- Multi-language + RTL/LTR.
- Multi-currency.
- Multi-store on one tenant hierarchy.
- Tax/VAT computation (consumed by ordering 04 and accounting 06).

## Sub-files
- `languages-rtl.md`, `currencies.md`, `multi-store.md`, `tax-vat.md`.

## Integration events
- Publishes `ExchangeRatesUpdated`, `TaxConfigChanged`.

## Definition of done
- A store runs in a second language (RTL) and currency; tax computes correctly per
  category/region and matches invoice/accounting totals.

## ASVS focus
- V5 (locale/currency input), V11 (tax calculation correctness).
