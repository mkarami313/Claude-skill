# 02 · Categories, brands & tags

## Categories
- `Category` is a self-referencing tree (parent/children) per tenant.
- Fields: `Name`, `Slug`, `ParentId`, `SortOrder`, image, SEO fields (11), active flag.
- A product belongs to one or more categories (many-to-many).
- Store a materialized path or use closure table for fast subtree queries and breadcrumbs.

## Brands
- `Brand`: `Name`, `Slug`, logo, description, SEO fields. A product has an optional brand.

## Tags / labels
- Free-form `Tag`s (many-to-many) for merchandising and filtering (e.g. "new", "eco").

## Rules
- Slugs unique per tenant within their type; prevent cycles in the category tree.
- Deleting a category requires reassigning or detaching its products (no orphans);
  prefer soft-archive over hard delete to preserve links.
- Expose category tree and breadcrumb queries for the storefront; cache per tenant.

## API surface
- CRUD categories/brands/tags; move category (reparent); assign products to categories;
  get tree / get breadcrumb / list by category (delegates product filtering to module 12).
