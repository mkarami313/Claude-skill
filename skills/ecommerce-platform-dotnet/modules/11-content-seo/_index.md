# Module 11 · Content & SEO — index

Backend serves content and SEO data; the headless frontend renders it.

## Scope
- CMS: pages, blog, banners, menus.
- Media library (shared with catalog upload safety).
- SEO metadata + structured data (schema.org).
- Sitemap, robots, redirects.

## Sub-files
- `cms-pages-blog.md`, `media-library.md`, `seo-metadata-schema.md`, `sitemap-redirects.md`.

## Integration events
- Publishes `ContentPublished` (optional, for cache/sitemap refresh).

## Definition of done
- Every indexable entity exposes editable SEO fields + schema payload; sitemap/robots served;
  redirects work; uploads validated and safe.

## ASVS focus
- V12 (uploads), V5 (output encoding for user/admin content).
