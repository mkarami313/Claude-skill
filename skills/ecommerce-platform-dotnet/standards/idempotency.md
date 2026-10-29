# Idempotency convention (read when writing anything that can be retried)

Networks retry, users double-click, gateways send duplicate callbacks, jobs re-run. A repeated
operation must not create a second order, charge twice, or double-post stock. One convention,
applied everywhere.

## Two cases

### 1. Inbound write requests (client → API)
- State-changing POSTs that must be safe to retry (checkout/place order, start payment, apply
  a bulk action) accept an **`Idempotency-Key`** header (client-generated GUID).
- Store processed keys with the resulting response (per tenant + endpoint) for a retention
  window. A repeat with the same key returns the **same** result instead of acting again.
- Scope the key to the operation; reject a reused key with a different body.

### 2. Internal / event-driven work (consumers, jobs, callbacks)
- Every integration-event consumer dedupes by the event's **id** (outbox guarantees
  at-least-once, not exactly-once) — record handled ids, skip duplicates.
- Payment callbacks: dedupe by the gateway reference; a second callback for an already-verified
  transaction is a no-op (see payments 05).
- Scheduled billing/renewals: idempotent per (subscription, period) so a re-run never
  double-bills (subscriptions 23).
- Stock movements and journal entries: idempotent per (referenceType, referenceId) so an event
  replay doesn't double-post (inventory 03, accounting 06).

## Implementation notes
- Prefer a unique constraint on the natural idempotency key in the DB so concurrent duplicates
  collide at the data layer, then handle the conflict gracefully.
- Keep the processed-key / handled-event records tenant-scoped and pruned by a job.

## Rule of thumb
If an operation changes money, stock, or creates a document, it must be idempotent. Decide the
key before writing the handler, not after a production incident.
