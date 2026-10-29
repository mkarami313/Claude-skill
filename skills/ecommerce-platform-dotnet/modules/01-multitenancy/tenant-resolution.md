# 01 · Tenant resolution

Determine the current tenant from a **trusted** source only, early in the pipeline.

## Resolution order
1. **JWT `tenant` claim** for authenticated API calls (validated with the token signature).
2. **Host / subdomain** mapping for anonymous/storefront calls: `store1.example.com` or a
   custom domain → tenant, via a cached `host → tenantId` lookup table.
3. Optional explicit admin context for platform-level staff (super-admin), scoped carefully.

## Rules
- **Never** read the tenant from a request body, query string, or arbitrary header the
  client controls.
- Resolve in middleware; store the result in a scoped `ITenantContext.Current`.
- If no tenant resolves and the endpoint is tenant-scoped → 400/404 (don't leak existence).
- Platform (cross-tenant) endpoints are explicitly marked and require super-admin.
- Cache host→tenant with invalidation on domain changes; custom domains verified before use.

## Middleware sketch (behavioral spec)
- Extract candidate (claim/host) → look up tenant → ensure tenant is active →
  set `ITenantContext` → continue. Reject disabled/suspended tenants.
