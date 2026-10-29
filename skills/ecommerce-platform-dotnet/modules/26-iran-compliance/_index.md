# Module 26 · Iran market compliance — index

Legal/market requirements specific to selling online in Iran. These are not optional for a
real store in this market, so they get a dedicated module rather than being scattered.

## Scope
- سامانه مؤدیان (Moadian): issue and submit electronic tax invoices to the national system.
- نماد اعتماد الکترونیک (E-Namad): the trust-seal requirements an Iranian shop must meet.
- Market conventions touched elsewhere (Jalali dates, IRR/IRT, Iranian gateways, SMS
  patterns) are handled in their own modules (14, 05, 15) — linked, not duplicated.

## Sub-files
- `moadian.md` — electronic tax-invoice submission.
- `enamad.md` — trust-seal compliance requirements.

## Integration events
- Consumes `InvoiceIssued`/`OrderPaid` (04) to generate and submit Moadian invoices;
  publishes `MoadianInvoiceAccepted`/`MoadianInvoiceRejected`.

## Definition of done
- Official invoices are transformed to the Moadian schema, signed, and submitted with the
  returned reference stored; failures retry and surface clearly; the store exposes the data
  E-Namad verification needs. Feature-flagged per tenant (not every seller is registered).

## ASVS focus
- V8 (invoice integrity + signing), V9/SSRF (government endpoints allow-listed), V4 (per-tenant credentials).

## Caveat
- Moadian/E-Namad specs and endpoints change and are authoritative only from official sources
  (tax.gov.ir / enamad.ir). Treat the details here as structure, and verify current field
  lists, signing, and endpoints against official docs at implementation time.
