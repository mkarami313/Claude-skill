# 12 · Indexing & sync

## Engine
- **OpenSearch** is the locked default (Apache-2.0, no licensing issues), behind an
  `ISearchEngine` abstraction so another engine can be swapped later. Build against OpenSearch;
  don't re-decide the engine per task.

## Index model
- One logical index per tenant (or a shared index with a mandatory `tenantId` filter —
  always filter by tenant on every query).
- Document per product (or per variant) with: name, description, brand, categories,
  filterable attributes, price, rating, popularity/sales score, availability, tags.

## Sync
- Subscribe to `ProductChanged`/`Created`/`Deleted` (02), stock (03), reviews (09) →
  enqueue a re-index job (20) for the affected document (near-real-time).
- Bulk reindex job for full rebuilds; versioned index + alias swap for zero-downtime rebuilds.
- Make indexing idempotent and resilient to out-of-order events (use updatedAt).

## Rules
- Never index secrets; only storefront-visible fields.
- Tenant filter is non-optional on every search request.
