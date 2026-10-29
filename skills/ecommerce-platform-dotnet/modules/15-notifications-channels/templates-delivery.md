# 15 · Templates & delivery

## Templates
- `NotificationTemplate`: key (e.g. `order.paid`), channel, locale, subject/body with
  placeholders; per-tenant overrides of system defaults.
- Render with a safe templating engine; localized per customer locale (14).

## Delivery pipeline
- Event handler builds a message from a template → enqueue a send job (Hangfire, module 20).
- Retry with backoff on transient failures; dead-letter after max attempts.
- Record `NotificationLog`: template, channel, recipient (masked), status, provider id,
  timestamps — **no OTP, no full PII, no secrets** in the log.
- Respect quiet hours, frequency caps, and consent/unsubscribe (10).

## Preferences
- Per-customer channel preferences and unsubscribe handling; transactional messages
  (OTP, order status) are exempt from marketing opt-out.

## API surface
- CRUD templates; preview render; delivery log/status; manage preferences/unsubscribe.
