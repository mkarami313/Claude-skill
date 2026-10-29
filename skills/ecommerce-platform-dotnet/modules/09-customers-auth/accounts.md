# 09 · Customer accounts

## Model
- `Customer`: `Id`, `TenantId`, linked `UserId`, name, phone (verified), email (verified),
  marketing consent flags, created date.
- `Address`: multiple per customer (title, recipient, phone, province/city, postal code,
  line, geo, default flag).

## Self-service
- View/edit profile; manage address book; my-orders & returns (04); wallet (05);
  wishlist/saved items (04).
- Change phone/email with re-verification (OTP/email).
- **Delete account** (data-protection): anonymize PII, keep order records as required by law;
  honor consent withdrawal.

## Rules
- A customer accesses only their own resources (per-object authz; tested).
- PII minimized and protected (encryption at rest for sensitive fields); consent recorded.

## API surface
- Get/update profile; CRUD addresses; set default address; delete/anonymize account.
