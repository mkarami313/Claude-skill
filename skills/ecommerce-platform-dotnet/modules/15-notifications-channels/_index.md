# Module 15 · Notifications & channels — index

Reaches customers across SMS, email, push, and messaging bots — and lets those channels
transact through the same API.

## Scope
- Provider abstractions (SMS/email/push) with pluggable adapters.
- Templated, localized, queued delivery.
- Bot channels (Bale/Telegram/WhatsApp) and other sales channels.
- Inbound webhook security.

## Sub-files
- `providers.md`, `templates-delivery.md`, `bot-channels.md`, `webhooks-security.md`.

## Integration events
- Consumes order/payment/shipment/return events, OTP requests (09), campaigns (10),
  loyalty/tier changes (10) → sends messages.

## Definition of done
- Transactional events deliver via the tenant's chosen provider with retry; OTP/PII never
  in logs; a second channel (e.g. Bale bot) can browse/order via the API; inbound webhooks verified.

## ASVS focus
- V7 (no secrets in logs), V8 (verify inbound webhook/bot signatures), V9/SSRF.
