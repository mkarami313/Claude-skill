# 12 · Facets & sorting

## Faceted filtering
- Facets from indexed fields: category, brand, price range, rating, availability, and any
  attribute marked `IsFilterable` (02).
- Each facet value returns a **count** reflecting the current filter set (post-filter counts).
- Multi-select within a facet (OR) and across facets (AND); price as range slider.

## Sorting
- Options: relevance (default for queries), newest, price asc/desc, best-selling,
  top-rated, most popular. Default sort for browse (no query) is configurable per tenant.

## Empty & edge results
- Zero results → show suggestions, popular items, or relaxed filters, never a blank page.
- Guard against facet explosion; cap values shown, provide "show more".

## API surface
- Search/browse with facets + counts; available sort options; facet value lists.
