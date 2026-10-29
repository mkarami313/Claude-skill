# 25 · Admin API conventions

The back-office is an API consumed by an admin SPA/app (headless, like the storefront).

## Conventions (shared across all admin endpoints)
- Routes under `/api/v1/admin/...`, separate from storefront routes, with staff-only policies.
- Uniform **list** contract: filtering, sorting, and pagination (cursor or page) with a
  consistent query + response envelope, so every admin grid works the same way.
- Every list endpoint supports export (16) for its data.
- DTOs are admin-shaped (may expose more fields than storefront DTOs) but still never leak
  secrets (gateway keys, hashes, OTPs).

## Cross-module composition
- The admin dashboard composes read models from several modules (sales from 16, open orders
  from 04, low stock from 03, tickets from 09) via their contract queries — the admin module
  orchestrates, it doesn't own that data.
- Role-specific admin homes (warehouse, support, accountant, vendor) surface only their slice.

## Rules
- Deny by default; each endpoint declares a specific permission (RBAC from 18).
- Tenant-scoped like everything else; platform super-admin cross-tenant views are a separate,
  tightly-controlled set of endpoints.

## API surface
- Shared list/filter/paginate/export primitives; dashboard composition endpoints per role.
