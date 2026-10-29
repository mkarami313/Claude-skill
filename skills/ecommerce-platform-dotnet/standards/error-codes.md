# Error codes & API error shape (read when designing endpoints/handlers)

One consistent error contract across every module so clients handle failures uniformly.

## Wire shape — RFC 7807 Problem Details
Every error response is Problem Details with a stable, machine-readable `code`:
```
{
  "type": "about:blank",
  "title": "product.slug_taken",
  "status": 409,
  "detail": "Slug already in use.",
  "errors": { "slug": ["Already in use."] }   // present for validation (400)
}
```
- `title` carries the stable `code`; clients branch on `code`, not on `detail` (which is
  human text and may be localized).
- Validation failures (from FluentValidation) use 400 with a field→messages `errors` map.

## Code convention
- Format: `<area>.<reason>` in lower_snake, area = module/aggregate.
  Examples: `product.slug_taken`, `order.not_found`, `payment.verify_failed`,
  `coupon.usage_limit_reached`, `stock.insufficient`, `giftcard.expired`,
  `auth.otp_locked`, `tenant.suspended`.
- Codes are part of the API contract — don't rename a published code; add a new one instead.
- `Error.Code` in the `Result` type (see reference-implementation) IS this code.

## HTTP status mapping (central middleware)
- validation → 400 · unauthenticated → 401 · forbidden → 403 · not found → 404 ·
  business-rule conflict → 409 · rate limited → 429 · unexpected → 500 (no internal detail
  leaked; log server-side with a correlation id).

## Rules
- Never leak stack traces, SQL, or secrets in `detail`.
- Each module keeps its codes in one place (a static class) so they're discoverable and stable.
