# 09 · Authentication & OTP

## Identity
- ASP.NET Identity as the user store (password hashing, lockout, user management).
- `ApplicationUser` carries `TenantId`; staff and customers are users differentiated by role.

## Primary login: phone + OTP
- `OtpCode`: hashed code, phone, purpose (login | verify | reset), `ExpiresAtUtc` (≤2 min),
  attempt count, consumed flag.
- Generate 6 digits with `RandomNumberGenerator`; store **hashed**; send via SMS provider (15).
- Verify: compare hash, check not expired/consumed, enforce max attempts → lockout.
- **Rate-limit** requests and verifications per phone AND per IP (anti-automation).

## Optional methods
- Email + password (Identity policy: length, breach check if available, lockout).
- Social login (OAuth) where configured.

## Rules
- Never log OTPs or tokens.
- Same response time/message whether or not the phone exists (no enumeration).
- New-device/first login may require extra verification.

## API surface
- Request OTP; verify OTP → issue tokens (tokens-sessions.md); register; password reset.
