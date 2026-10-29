# Module 09 · Customers & auth (CRM) — index

Identity + the customer relationship. Read `security/secure-dotnet-patterns.md` with this.

## Scope
- Authentication (phone + OTP primary; optional email/password, social).
- Tokens & sessions (JWT access + rotating refresh), RBAC.
- Customer accounts (profile, addresses, wishlist, wallet link).
- CRM (profiles, segmentation, LTV).
- Support tickets and product reviews/Q&A.

## Sub-files
- `authentication-otp.md`, `tokens-sessions.md`, `accounts.md`,
  `crm-segmentation.md`, `support-reviews.md`.

## Integration events
- Publishes `CustomerRegistered`, `CustomerSegmentChanged`.
- Consumes order/payment events to build CRM history & segments.

## Definition of done
- Phone-OTP login with lockout + rate limit; tokens rotate/revoke; a customer sees only
  their own data (per-object authz tested); tickets and verified-purchase reviews work.

## ASVS focus
- V2 (auth), V3 (session/tokens), V4 (per-object), V8 (PII protection).
