# Module 02 · Catalog — index

The product data model. Flexible enough that any store can model its goods without schema
changes. Stock lives in module 03; this module owns the product definition.

## Scope
- Product types (physical, digital, service/bookable, subscription, bundle).
- Variants (option combinations) with their own SKU and price.
- Dynamic attributes per category (filterable, typed).
- Category tree, brands, tags, and media (gallery/video).

## Sub-files
- `product-model.md` — product aggregate, types, pricing basics.
- `variants-attributes.md` — variants, options, dynamic attribute system.
- `categories-brands.md` — category tree, brands, tags, associations.
- `media.md` — images/video, safe upload handling.

## Integration events
- Publishes `ProductCreated`, `ProductChanged`, `ProductDeleted` (consumed by search 12,
  analytics 16). Consumes nothing critical.

## Definition of done
- A product with variants, typed attributes, categories, brand, and media can be created,
  edited, and read via API; filterable attributes are indexable by module 12.

## ASVS focus
- V5 (input validation for attributes & import), V12 (media upload safety).
