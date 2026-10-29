# 01 · Data isolation

Make it impossible for one tenant to touch another's data by default.

## Mechanism
- All tenant-owned entities implement `ITenantEntity { Guid TenantId }`.
- In each module's `DbContext`, apply a **global query filter**:
  every `ITenantEntity` set is filtered by `e.TenantId == _tenantContext.Current`.
- **Auto-stamp** `TenantId` on insert inside `SaveChanges`; never bind it from client input.
- For raw/Dapper queries, always include an explicit `tenant_id = @tenant` predicate.

## Defense in depth
- Add a Postgres Row-Level Security policy as a second layer where feasible.
- Per-object checks in handlers still verify ownership (belt and braces) — see security.
- Platform-level queries that intentionally cross tenants must opt out of the filter
  explicitly (`IgnoreQueryFilters`) and are allowed only for super-admin use cases.

## Mandatory tests
- Seed tenant A and tenant B. Assert:
  - Querying as A never returns B's rows.
  - Fetching B's record id as A returns not-found, not forbidden (no existence leak).
  - Insert as A always stamps A's `TenantId` regardless of any client-sent value.
