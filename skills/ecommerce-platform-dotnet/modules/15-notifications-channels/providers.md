# 15 · Providers (SMS / email / push)

## Abstractions
- `ISmsProvider`, `IEmailProvider`, `IPushProvider` — each `SendAsync(message)` returning a
  delivery result/id. Multiple adapters per type; tenant selects active provider(s).

## Adapters
- **SMS:** several Iranian SMS panels (e.g. Kavenegar, SMS.ir, Melipayamak) — pattern/OTP
  and bulk send. **Email:** SMTP + transactional (e.g. Mailgun/SES-style). **Push:** web
  push + mobile (FCM/APNs).

## Rules
- Credentials per tenant, encrypted, never logged or returned to the frontend.
- Failover: optionally try a secondary provider on failure.
- OTP SMS uses approved patterns where required by the panel/regulator.
- All outbound calls allow-listed + TLS; respect rate limits of the provider.

## API surface
- Configure providers per tenant; send (internal use cases); delivery-status callback intake.
