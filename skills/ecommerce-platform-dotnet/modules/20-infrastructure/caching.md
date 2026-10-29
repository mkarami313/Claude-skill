# 20 · Caching

## Layers
- **Distributed cache (Redis):** sessions/refresh-token lookups, rate-limit counters,
  tenant/host resolution, computed read models (dashboards, facet counts, product detail).
- **Response/output cache** for anonymous storefront reads (product/category pages) with
  short TTLs and tag-based invalidation.
- **CDN** in front for media and cacheable responses.

## Rules
- **Tenant-key every cache entry** (prefix with tenantId) — never serve one tenant's cached
  data to another.
- Invalidate on write: `ProductChanged` → bust product/facet caches; content publish → bust
  page/sitemap caches.
- Cache only non-sensitive data; never cache secrets or per-user private data in shared keys.
- Set sensible TTLs; prefer stale-while-revalidate for heavy aggregates.

## API surface
- Cache abstraction (`ICacheService`) used by read-heavy queries; invalidation hooks on events.
