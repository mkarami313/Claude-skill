# 15 · Bot & sales channels

The headless API lets non-web channels both notify and sell. One core, many front-ends.

## Messaging bots (Bale / Telegram / WhatsApp)
- A bot client (separate process) talks to the platform API like any other client, with a
  channel service account/token scoped to a tenant.
- Capabilities: browse catalog, search, build a cart, place an order, pay (redirect link),
  check order status, receive notifications.
- Map a bot user → platform customer (link by phone/OTP) so orders attach to an account.
- **Bale** is first-class for the Iranian market; the same handler shape serves Telegram/WhatsApp.

## Other channels
- PWA and native app consume the same API.
- Social commerce (Instagram shop) and external marketplace feeds (export product feed).
- In-store POS (module 17) shares cart/stock/customer via the API.

## Rules
- Treat all inbound bot updates as untrusted; verify signatures/tokens (see webhooks-security).
- Never expose secrets to the bot client; scope its permissions tightly.
- Each channel respects tenant feature flags and provider config.

## API surface
- Bot-facing endpoints reuse storefront + checkout APIs; channel linking; notification push to channel.
