# 16 · Exports & external integrations

## Exports
- Any report exportable to Excel/CSV; large exports run as background jobs and deliver a
  download link when ready.
- Scheduled report emails (e.g. weekly sales summary) via notifications (15).

## External analytics
- Per-tenant configuration for Google Analytics, Google Tag Manager, Meta Pixel, and
  similar — the frontend loads these; the backend exposes the tenant's configured ids and
  any server-side event forwarding (consent-gated).
- Optional data export/stream to a data warehouse via the event stream.

## Rules
- Respect privacy/consent; don't forward PII without consent.
- Tenant-scoped; third-party ids stored in tenant config (01).

## API surface
- Request export; export status/download; configure external analytics ids;
  schedule report emails.
