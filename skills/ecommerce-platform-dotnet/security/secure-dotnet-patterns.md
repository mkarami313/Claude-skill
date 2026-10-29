# Secure .NET 10 patterns (read when writing auth / input / crypto / upload / payment)

Concrete, copy-adaptable patterns. Keep them minimal; prefer framework features over custom code.

## Input validation (DTO + FluentValidation)
- Bind requests to **DTOs**, never to EF entities (prevents mass-assignment / over-posting).
- Validate with FluentValidation; return 400 with a safe error list.
- Allow-list enums and known values; reject unknown fields.

## Authentication & tokens
- ASP.NET Identity for password hashing and user store.
- **Access token:** JWT, short TTL (~15 min), signed with a key from secret store.
- **Refresh token:** opaque, random (`RandomNumberGenerator`), stored **hashed**, rotated
  on each use, revocable; detect reuse → revoke the whole chain.
- **OTP:** 6 digits, hashed at rest, single-use, ≤2 min TTL, max attempts + lockout,
  rate-limited per phone and per IP.
- Validate issuer, audience, lifetime, and signing key on every request.

## Authorization (deny by default + per-object)
- Global fallback policy requires authenticated user.
- `[Authorize(Policy = "...")]` per endpoint; roles/permissions via claims.
- **Always** verify the target record's `TenantId` and owner match the caller before
  read/update/delete — this stops IDOR. Do it in the handler, not only in a filter.

## Multi-tenant safety
- Resolve tenant from a trusted source (subdomain/host or validated token claim),
  never from a client-supplied body field.
- Apply EF global query filter on `TenantId`; set it from the current tenant context.
- Add a DB check / test that no query can cross tenants.

## Crypto & secrets
- Secrets from environment / secret manager; never in `appsettings.json` committed to git.
- Hashing: Identity defaults (PBKDF2) or Argon2 for passwords; SHA-256+salt only for
  non-password tokens.
- Use `RandomNumberGenerator` for all tokens/codes — never `Random`.
- Protect data at rest with the ASP.NET Data Protection API or DB-level encryption.

## Payment callback verification (critical)
- Treat the user's return from the gateway as untrusted.
- On callback: look up the pending transaction by your own id, call the gateway's
  **verify** endpoint server-to-server, confirm amount + status match your record, then
  mark paid in a single DB transaction. Make it idempotent (ignore duplicate callbacks).

## File upload
- Allow-list content types + extensions, cap size, generate a new random filename,
  store outside the web root (or object storage), never execute, re-encode images.

## HTTP hardening
- Enforce HTTPS + HSTS; set CSP, `X-Content-Type-Options: nosniff`, `Referrer-Policy`.
- Rate-limit login, OTP, checkout, and coupon endpoints (ASP.NET rate limiting or Redis).
- Return generic error messages to clients; log details server-side only.

## Outbound calls (SSRF-safe)
- Allow-list gateway/SMS/image hosts; verify TLS; set timeouts; no raw user URLs.
