# 11 · SEO metadata & structured data

Expose SEO data; the frontend renders tags and JSON-LD.

## Per-entity SEO fields
- For product/category/brand/page/post: `MetaTitle`, `MetaDescription`, `CanonicalUrl`,
  `Slug`, `OgImage`, `NoIndex` flag, and locale alternates (14).
- Stored as a reusable `SeoMetadata` value object attached to each entity.

## Structured data (schema.org)
- Serve JSON-LD payloads per entity: `Product` (+ `Offer`, `AggregateRating`, availability,
  price), `BreadcrumbList`, `Article` (blog), `Organization`, `WebSite` (sitelinks search).
- Keep payloads consistent with live price/stock/rating from catalog (02), inventory (03),
  reviews (09).

## Rules
- Slugs unique per tenant per locale; changing a slug creates a 301 (see sitemap-redirects).
- Output-encode all SEO text; never inject unescaped user content.

## API surface
- Get/update SEO metadata per entity; get JSON-LD for an entity (storefront).
