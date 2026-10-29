# 24 · Platform migration

One-time moves from another e-commerce platform. Each source is an adapter mapping its schema
to our model; the import engine (bulk-import.md) does the actual writing.

## Adapter model
- `IMigrationSource` per platform: WooCommerce, Shopify, legacy custom, generic spreadsheet.
- Each reads the source export (file, or API with credentials) and yields normalized records:
  products (+variants, categories, images), customers (+addresses), orders (historical),
  coupons, reviews.

## Mapping concerns
- Map external ids → new ids and keep a **crosswalk table** so related records (order →
  product, order → customer) relink correctly.
- Media: fetch images from the source (allow-listed hosts, SSRF-safe) into our media store (11).
- Historical orders imported as read-only snapshots (don't re-trigger payment/stock/accounting
  side effects — import them in a "historical" mode that skips events).
- Preserve slugs where possible and create 301 redirects (11) from old URLs to keep SEO.

## Rules
- Run in stages (catalog → customers → orders) respecting dependencies; resumable.
- Dry-run first; produce a reconciliation report (counts matched vs source).
- Tenant-scoped; credentials for source APIs encrypted; never block on source downtime (queue/retry).

## API surface
- Configure a migration source; map fields; dry-run; run staged; crosswalk + reconciliation report.
