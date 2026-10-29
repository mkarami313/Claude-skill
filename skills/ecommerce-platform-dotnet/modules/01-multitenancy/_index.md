# Module 01 · Multi-tenancy (white-label) — index

The backbone of "any site on one core". One store = one tenant, isolated on a shared DB,
each with its own brand, domain, enabled modules, and providers.

## Scope
- Resolve the current tenant from a trusted source on every request.
- Isolate all tenant data with an EF global query filter on `TenantId`.
- Store per-tenant white-label config, enabled modules (feature flags), and provider choices.

## Sub-files
- `tenant-resolution.md` — how the current tenant is determined and enforced.
- `data-isolation.md` — `ITenantEntity`, global filter, auto-stamping, isolation tests.
- `tenant-config.md` — tenant aggregate, branding, feature flags, provider selection.

## Integration events
- Publishes `TenantProvisioned`, `TenantModulesChanged`.

## Definition of done
- Every tenant-owned query is filtered; cross-tenant read/write is impossible and tested.
- Tenant is never taken from a client body/header.
- A single endpoint returns the tenant's branding + enabled modules to the frontend.

## ASVS focus
- V4 (per-object access control), V1 (isolation / trust boundary).
