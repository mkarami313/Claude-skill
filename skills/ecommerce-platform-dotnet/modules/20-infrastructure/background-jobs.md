# 20 · Background jobs & outbox

## Jobs (Hangfire)
- Use Hangfire (Postgres storage) for: notifications/campaign sends, bulk import/export,
  report generation, image processing, reindexing, segment computation, reorder suggestions,
  reservation expiry, exchange-rate refresh, settlement runs.
- Job types: fire-and-forget, delayed (e.g. abandoned-cart reminder), recurring (cron).
- Idempotent handlers; retries with backoff; dead-letter + alert on repeated failure.

## Outbox (reliable events)
- Domain/integration events are written to an **outbox** table in the same transaction as the
  state change, then a dispatcher publishes them to the bus → consumers.
- Guarantees at-least-once delivery; consumers are idempotent.

## Rules
- Jobs run tenant-aware (carry tenant context explicitly; no ambient web context).
- Long/heavy work never runs inline in a request; enqueue instead.
- Secure the Hangfire dashboard (auth; admin only).

## API surface
- Job scheduling helpers; outbox dispatcher; recurring-job registration per module.
