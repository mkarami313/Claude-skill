# 14 · Languages & RTL

## Model
- `Locale`: code (e.g. `fa-IR`, `en-US`), name, direction (RTL | LTR), active, default flag.
- `Translation`: entity + field + locale → translated text, for product names/descriptions,
  categories, CMS, attributes, etc. Fallback to the default locale when missing.
- UI/API message catalogs (resource files) for system strings.

## Rules
- Serve `direction` per locale so the headless frontend renders RTL (Persian) or LTR.
- Content localized per-field; untranslated fields fall back gracefully.
- Locale resolved from customer preference, URL/subpath, or Accept-Language.
- Dates: expose both Gregorian and Jalali where the locale is Persian; store UTC internally.
- Numbers/currency formatting metadata per locale.

## API surface
- CRUD locales; get/set translations per entity; get localized content; message catalogs.
