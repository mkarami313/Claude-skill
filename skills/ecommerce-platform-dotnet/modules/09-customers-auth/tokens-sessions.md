# 09 · Tokens, sessions & RBAC

## Tokens
- **Access token:** JWT, short TTL (~15 min), signed with a key from the secret store;
  claims include user id, tenant, roles/permissions.
- **Refresh token:** opaque random value, stored **hashed**, with expiry and device info;
  rotated on each use; old one revoked. Reuse of a rotated token ⇒ revoke the whole chain
  (theft detection).
- Validate issuer, audience, lifetime, signature on every request.

## Sessions / revocation
- Maintain a refresh-token store per user/device; support "log out everywhere".
- Short access TTL limits blast radius; revocation acts on refresh tokens.

## RBAC
- Roles: Customer, plus staff roles (Admin, Operator, Warehouse, Support, Accountant,
  Vendor — module 13). Permissions as claims; policies per endpoint.
- Deny-by-default global authorization fallback; `[Authorize(Policy=...)]` per endpoint.
- Per-object checks (owner/tenant) remain mandatory regardless of role.

## API surface
- Refresh token; revoke/logout (single + all devices); list active sessions.
