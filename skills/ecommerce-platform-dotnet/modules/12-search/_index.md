# Module 12 · Search & discovery — index

Fast, typo-tolerant, Persian-aware search with faceted filtering and recommendations.

## Scope
- Search index kept in sync with the catalog.
- Query handling (Persian/finglish, typo tolerance, synonyms).
- Faceted filters + sorting.
- Recommendations & merchandising.

## Sub-files
- `indexing-sync.md`, `query-persian.md`, `facets-sorting.md`,
  `recommendations-merchandising.md`.

## Integration events
- Consumes `ProductChanged`/`ProductCreated`/`ProductDeleted` (02), `StockAdjusted` (03),
  review changes (09) to re-index.

## Definition of done
- Catalog changes reflect in search within seconds; Persian/typo queries return sensible
  results; facets show correct counts; merchandising overrides apply; results tenant-scoped.

## ASVS focus
- V5 (query sanitization), V9/SSRF (search cluster calls allow-listed), V4 (tenant filter in index).
