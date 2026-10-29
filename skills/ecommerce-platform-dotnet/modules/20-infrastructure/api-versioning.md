# 20 · API, versioning & docs

## API design
- REST with Controllers; resource-oriented routes; DTOs in/out (never entities).
- URL versioning: `/api/v1/...`; never break a published version; add v2 for breaking changes.
- Consistent envelope: data + pagination metadata; errors as Problem Details (RFC 7807).
- Pagination (cursor or page), filtering, sorting conventions shared across modules.

## Hardening (cross-cuts every endpoint)
- Global auth fallback (deny by default); per-endpoint policies; per-object checks in handlers.
- **Rate limiting** (ASP.NET rate limiter or Redis) on auth, OTP, checkout, coupon, search,
  webhooks; stricter for anonymous.
- Request size limits; input validation (FluentValidation); output encoding.
- Security headers (HSTS, CSP, nosniff, Referrer-Policy); CORS allow-list per tenant domain.

## Docs
- OpenAPI/Swagger generated; document auth, versions, and error shapes.
- Expose the contract so frontends, apps, and bots consume a single source of truth.

## API surface
- Shared middleware/pipeline: versioning, auth, rate limit, validation, error handling, CORS.
