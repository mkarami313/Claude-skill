# 17 · Offline resilience & sync

Stores lose connectivity; the till must keep selling.

## Approach
- The POS client caches catalog, prices, and stock snapshots locally.
- Sales made offline are queued locally with a client-generated **idempotency key**.
- On reconnect, the client replays queued sales to the API; the server processes each once
  (idempotent order creation) and resolves stock.

## Conflict handling
- Stock may have changed while offline → server flags oversell conflicts for review rather
  than silently failing; configurable policy (allow backorder vs reject).
- Prices use the snapshot at sale time but are validated on sync; large deltas flagged.

## Rules
- Idempotency prevents duplicate orders on retry.
- Offline window is bounded; stale snapshots warn the cashier.
- Sync status visible; unsynced sales clearly marked.

## API surface
- Pull catalog/stock snapshot; batch sync offline sales (idempotent); conflict report.
