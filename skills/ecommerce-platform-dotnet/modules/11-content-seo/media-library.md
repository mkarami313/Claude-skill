# 11 · Media library

A shared, tenant-scoped asset store for content and products.

## Model
- `MediaAsset`: storage key, type, original filename, size, dimensions, alt text, folder/tags,
  uploaded-by, created date.
- Folders/tags for organization; search by name/tag.

## Storage & delivery
- Object storage (S3-compatible) or off-webroot; served via CDN (20); responsive sizes
  generated as a background job.

## Upload safety (same rules as catalog media)
- Allow-list type/extension, cap size, verify magic bytes, random filename, re-encode images,
  store off-webroot, never execute, scan where possible.

## Rules
- Tenant-scoped; permissioned; referenced by catalog (02) and CMS (11).
- Deleting an asset checks references first (or soft-delete).

## API surface
- Upload; list/search; move/tag; delete (with reference check); get signed URL.
