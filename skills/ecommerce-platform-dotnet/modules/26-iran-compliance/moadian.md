# 26 · سامانه مؤدیان (Moadian electronic tax invoice)

Iran's national system for submitting electronic tax invoices (صورتحساب الکترونیکی). Sellers
registered as taxpayers must submit invoices to it. Verify current specs against official
docs — they change.

## Model
- `MoadianInvoice`: `Id`, `TenantId`, source `InvoiceId` (from ordering 04), the Moadian
  payload (mapped fields), unique tax id (شماره منحصر به فرد مالیاتی / "taxid"), `Status`
  (Pending | Submitted | Accepted | Rejected), returned reference, error details, timestamps.
- Per-tenant config: memory/taxpayer id (شناسه یکتای حافظه مالیاتی), economic code, private
  key / certificate for signing — all encrypted, never exposed.

## Flow (idempotent, async)
1. On `InvoiceIssued`/`OrderPaid` (04) for a registered tenant, build the Moadian invoice:
   map seller, buyer, line items, amounts, and VAT (from tax module 14) to the required schema.
2. Generate the unique tax id per the system's algorithm; **sign** the payload with the
   tenant's key.
3. Submit server-to-server to the Moadian API (allow-listed host, TLS); store the returned
   reference.
4. On acceptance → `MoadianInvoiceAccepted`; on rejection → record errors, retry/fix,
   surface to staff. Run submission via a background job with retries (don't block checkout).

## Rules
- Idempotent per source invoice — never submit the same invoice twice.
- A failed/rejected submission must be visible and actionable in the back-office (25).
- Credentials and keys per tenant, encrypted; signing happens server-side only.
- Support correction/void invoices per the system's rules.

## API surface
- Build+submit (from event); resubmit; invoice status; tenant Moadian config (keys encrypted).
