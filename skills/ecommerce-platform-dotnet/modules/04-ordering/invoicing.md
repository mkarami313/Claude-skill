# 04 · Invoicing

## Model
- `Invoice`: `Id`, `OrderId`, `TenantId`, `InvoiceNumber` (per-tenant legal sequence),
  `Type` (Proforma | Official), issue date, buyer + seller legal details, line snapshot,
  tax breakdown, totals, status (issued | paid | cancelled/credit-noted).
- Immutable once issued; corrections via a credit note / new invoice, never edits.

## Rules
- Proforma can be generated at checkout; official invoice on `OrderPaid`.
- Numbering is gapless and sequential per tenant per fiscal scope (legal requirement).
- Tax lines come from module 14; totals must equal the order snapshot.
- Store a rendered PDF (generate via the frontend/pdf tooling or a service) and the
  structured data; expose both.
- Feeds accounting (06): `InvoiceIssued` event posts the sales journal.

## Localization
- Supports Persian/official Iranian invoice fields and VAT presentation (module 14),
  Jalali date, and legal/tax identifiers from tenant config (01).

## API surface
- Generate proforma; issue official invoice; get invoice (owner/staff); credit note.
