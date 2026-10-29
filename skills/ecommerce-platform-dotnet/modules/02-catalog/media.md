# 02 · Product media

## Model
- `ProductMedia`: `ProductId` (and optional `VariantId`), `Type` (Image|Video|File|360),
  `Url`/storage key, `AltText`, `SortOrder`, dimensions.
- Images can be variant-specific (show the right color when a variant is selected).
- Support an ordered gallery, a primary image, video (hosted or embedded), and attachments
  (e.g. spec sheets) and optional 360° sets.

## Storage & delivery
- Store originals in object storage (S3-compatible) or off-webroot disk; serve via CDN (20).
- Generate responsive sizes/thumbnails as a background job (Hangfire); re-encode images.
- Reference by storage key; generate signed/public URLs as needed.

## Upload safety (security-critical)
- Allow-list content types + extensions; cap file size; verify magic bytes, not just
  extension; assign a new random filename; never execute uploaded content.
- Strip metadata; re-encode images to neutralize embedded payloads.
- Scan files where a scanner is available.

## API surface
- Upload media (returns storage key); attach/detach to product/variant; reorder; set primary.

## ASVS focus: V12 (file upload), V5 (alt-text/output encoding).
