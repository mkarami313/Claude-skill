# 12 · Recommendations & merchandising

## Recommendations
- Related products (same category/attributes), complementary (frequently bought together),
  "bestsellers in category", recently viewed, and personalized picks from browse/purchase
  history. Basic versions are rule/co-occurrence based; advanced ML lives in module 21.
- Served as slots the frontend requests by context (product page, cart, home).

## Merchandising controls
- Manual result ordering / pinning for a query or category.
- Boost rules: promote high-margin, new, or in-stock items; demote out-of-stock.
- Curated collections (hand-picked product lists) for campaigns.

## Rules
- Recommendations respect availability and tenant scope.
- Merchandising overrides are applied on top of relevance ranking, configurable per tenant.

## API surface
- Get recommendations for a context; manage pins/boosts; CRUD curated collections.
