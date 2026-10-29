# 15 · Inbound webhook security

Every inbound callback (payment gateway, SMS delivery, bot update, carrier tracking) is
untrusted until verified.

## Rules
- **Verify authenticity:** check the provider's signature/HMAC or shared secret on every
  inbound request; reject unsigned/invalid ones.
- **Idempotency:** dedupe by the provider's event id; process once.
- **Validate payload** against an expected schema; ignore unexpected fields.
- **Don't trust state in the payload** for money/stock decisions — re-verify server-to-server
  (payments: call Verify; see module 05).
- **Rate-limit** webhook endpoints; log receipts (no secrets); alert on anomalies.
- Respond fast (ack) and process asynchronously via a job (20) to avoid timeouts.

## Allow-listing
- Restrict outbound verification calls to known provider hosts (SSRF protection).

## API surface
- Webhook intake endpoints per provider type, each with signature verification middleware.
