# Security checklist — OWASP Top 10 + ASVS Level 2 (READ FOR EVERY MODULE)

Target: **ASVS L2**. Apply every item that touches the module you are building.
When you write auth, input, crypto, upload, or payment code, also read
`secure-dotnet-patterns.md`.

## Non-negotiable rules
- **Server is the source of truth.** Never trust client-sent prices, totals, tenant ids,
  roles, or discounts. Recompute and re-authorize on the server.
- **Deny by default.** Every endpoint requires explicit authentication + authorization
  unless deliberately marked public.
- **Validate every input** at the boundary (type, length, range, format). Reject, don't fix.
- **Never log secrets** — no passwords, tokens, OTPs, card data, full PII in logs.

## Mapped to OWASP Top 10 (2021)
- **A01 Broken Access Control** — enforce authorization on every action AND every object
  (IDOR: check the record belongs to the current user/tenant). Deny by default.
- **A02 Cryptographic Failures** — TLS everywhere; hash passwords with ASP.NET Identity
  (PBKDF2/Argon2); encrypt secrets at rest; no custom crypto.
- **A03 Injection** — only parameterized queries / EF Core; never string-concat SQL;
  encode output; validate/allow-list all input.
- **A04 Insecure Design** — threat-model each module; rate-limit sensitive flows
  (login, OTP, checkout); enforce business limits (max qty, one coupon rule).
- **A05 Security Misconfiguration** — secrets from env/secret store, never in source;
  disable detailed errors in prod; set secure headers (HSTS, CSP, X-Content-Type-Options).
- **A06 Vulnerable Components** — pin versions, run `dotnet list package --vulnerable`,
  patch regularly.
- **A07 Auth Failures** — MFA/OTP, lockout + backoff, rotate + revoke refresh tokens,
  short-lived access tokens, secure session handling.
- **A08 Data Integrity** — verify payment callbacks server-side against the gateway;
  sign/verify webhooks; validate deserialized data.
- **A09 Logging & Monitoring** — log auth events, access-control failures, payment events
  (no secrets); centralize; alert on anomalies.
- **A10 SSRF** — allow-list outbound URLs (gateways, SMS, image fetch); never fetch
  user-supplied URLs raw.

## ASVS L2 focus areas (verify per module)
- **V1 Architecture** — trust boundaries documented; secrets never client-side.
- **V2 Authentication** — OTP + password policy, lockout, token rotation.
- **V3 Session** — secure, httpOnly, sameSite cookies if used; token revocation.
- **V4 Access Control** — RBAC + per-object (tenant/owner) checks, deny by default.
- **V5 Validation/Encoding** — input validation + output encoding everywhere.
- **V7 Error/Logging** — safe errors to client, rich safe logs server-side.
- **V8 Data Protection** — classify PII; encrypt sensitive-at-rest; minimize retention.
- **V9 Communications** — TLS 1.2+; verify certs on all outbound calls.
- **V11 Business Logic** — anti-automation on checkout/OTP; enforce sequence + limits.
- **V12 Files/Resources** — validate upload type/size, store outside webroot, scan.
- **V13 API** — authz on every endpoint, rate limits, no mass-assignment (use DTOs).

## Per-module gate (must pass before "done")
1. Every endpoint has authentication + authorization + per-object check.
2. All inputs validated via DTOs/FluentValidation; no entity binding directly.
3. No secrets in code/logs; outbound calls allow-listed and over TLS.
4. Sensitive flows are rate-limited and audit-logged.
5. Security-relevant logic has tests (authz denial, tenant isolation, tamper attempts).
