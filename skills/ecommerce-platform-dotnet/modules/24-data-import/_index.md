# Module 24 · Data import & migration — index

Getting data in: both routine bulk imports (price/stock updates) and one-time migrations
from another platform (WooCommerce, Shopify, a legacy site, a spreadsheet export). A seller
won't adopt the platform if they can't bring their catalog and customers with them.

## Scope
- File-based bulk import (CSV/Excel) with validation and a dry-run.
- Platform migration adapters (map external schema → our model).
- Large-job handling, error reporting, and rollback/resume.

## Sub-files
- `bulk-import.md` — CSV/Excel import pipeline.
- `platform-migration.md` — adapters for other e-commerce platforms.

## Integration events
- Publishes `ImportCompleted` (with a summary); creates catalog/customer/stock records via
  those modules' use cases (not by writing their tables directly).

## Definition of done
- A seller uploads a product/customer file, sees a validation preview (dry-run), runs the
  import as a background job, and gets a per-row success/error report; a WooCommerce export
  can be mapped and imported; large files don't block requests; re-running is safe.

## ASVS focus
- V12 (upload safety), V5 (row validation), V4 (import scoped to the tenant).
