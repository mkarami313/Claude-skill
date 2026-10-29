# 16 · Funnel & event tracking

## Event model
- `AnalyticsEvent`: `TenantId`, session/customer id (pseudonymous), type
  (ProductViewed, SearchPerformed, AddedToCart, CheckoutStarted, OrderPlaced, OrderPaid),
  properties, timestamp, channel.
- Ingested via a lightweight endpoint (frontend) and from domain events (server-side).

## Conversion funnel
- View → Add-to-cart → Checkout → Paid, with drop-off between stages, segmentable by
  channel, campaign, device, or product.
- Abandoned-cart analysis and recovery attribution (10).

## Rules
- Respect consent (cookie/privacy); pseudonymize where possible; allow opt-out.
- Store events append-only; aggregate into read models/rollups for fast querying.
- Tenant-scoped; high-volume ingestion goes through a queue (20).

## API surface
- Ingest event; funnel report (range + segment); event explorer (aggregated).
