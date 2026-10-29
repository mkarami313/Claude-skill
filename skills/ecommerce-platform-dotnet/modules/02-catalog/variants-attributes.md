# 02 · Variants & dynamic attributes

## Variants
- A product has one or more `ProductVariant`s, each a combination of option values
  (e.g. Color=Red, Size=L).
- Variant fields: `Sku` (unique per tenant), `Price` override (optional), `Barcode`,
  `Weight`/dimensions (for shipping), and its own stock record (owned by module 03).
- `ProductOption` (e.g. Color) + `ProductOptionValue` (e.g. Red) define the axes;
  variants are the cartesian combinations the store chooses to sell.
- A product with no options still has exactly one default variant (keeps ordering uniform).

## Dynamic attributes (schema-less, filterable)
- `AttributeDefinition`: `Key`, `DisplayName`, `DataType` (string|number|bool|enum|date),
  `IsFilterable`, `IsVariantLevel`, optional allowed `EnumValues`, unit.
- Attribute definitions can be global or scoped to a category.
- `AttributeValue`: links product (or variant) → definition → typed value.
- Filterable attributes are projected into the search index (12) as facets.

## Rules
- Validate values against the definition's data type and allowed set; reject unknowns.
- Variant SKUs unique per tenant; prevent duplicate option combinations.
- Changing attribute definitions must not corrupt existing values (migrate or version).

## API surface
- Manage options/values; generate variants from selected option combinations;
  define attributes; set product/variant attribute values; bulk edit (background job).
