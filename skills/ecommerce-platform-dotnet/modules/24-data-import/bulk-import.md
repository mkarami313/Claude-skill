# 24 · Bulk import (CSV / Excel)

## Model
- `ImportJob`: `Id`, `TenantId`, `Type` (Products | Variants | Customers | Stock | Prices),
  source file ref, `Status` (Validating | Preview | Running | Completed | Failed),
  counts (total/ok/failed), created-by.
- `ImportError`: `ImportJobId`, row number, column, message — the per-row report.

## Pipeline
1. **Upload** the file (safe upload: validate type/size, off-webroot) — reuse media rules.
2. **Parse** with a streaming reader (don't load huge files into memory).
3. **Dry-run / preview:** validate every row (types, required fields, references like SKU
   exists, enum values) and return a summary + sample errors — no writes yet.
4. **Run** as a Hangfire background job: process in batches, upserting via the target
   module's use cases (catalog/customers/inventory), collecting per-row errors.
5. **Report:** downloadable error file; partial success allowed (good rows applied).

## Rules
- Column mapping is configurable (the seller maps their headers → our fields) and saved as a
  reusable template.
- Idempotent upsert keyed by a stable business key (SKU, phone/email) so re-running updates
  rather than duplicates.
- All writes tenant-scoped; large jobs chunked; progress reported.

## API surface
- Create import (upload + mapping); dry-run preview; start; job status + error report;
  save/reuse mapping template.
