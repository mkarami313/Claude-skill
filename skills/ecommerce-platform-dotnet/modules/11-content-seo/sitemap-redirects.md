# 11 · Sitemap, robots & redirects

## Sitemap & robots
- Generate `sitemap.xml` (and a sitemap index for large catalogs) per tenant/domain,
  including products, categories, pages, posts, with `lastmod` and locale alternates.
- Regenerate on content change (event) or on a schedule; cache and serve via the API/CDN.
- Serve per-tenant `robots.txt` (configurable disallow rules, sitemap link).

## Redirects
- `Redirect`: `TenantId`, `FromPath`, `ToPath`, type (301 | 302), active.
- Auto-create a 301 when a slug changes; allow manual redirects.
- Serve redirect rules to the frontend/edge; detect and report broken internal links.

## Rules
- Tenant/domain-scoped; avoid redirect loops (validate on create).
- Canonical URLs (seo-metadata) and redirects stay consistent.

## API surface
- Get sitemap/robots; CRUD redirects; broken-link report; trigger sitemap rebuild.
