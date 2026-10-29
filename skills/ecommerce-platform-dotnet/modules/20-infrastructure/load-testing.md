# 20 · Load & performance testing

An e-commerce platform's worst day is its best sales day. Prove the hot paths hold under the
spikes that actually happen (flash sales, campaign sends), before they happen.

## What to test (the paths that break under load)
- **Browse + search** (12): product listing, faceted search — highest read volume.
- **Checkout + place order** (04): the money path; includes stock reservation contention.
- **Payment callback** (05): bursts when many users return from the gateway at once.
- **Flash sale**: many users contending for limited stock of the same variant (worst-case
  concurrency on one `StockItem`).

## Approach
- Use k6 (or NBomber for in-.NET) with realistic scenarios and think-times, not flat loops.
- Run against a staging environment sized like prod; seed representative data volumes.
- Model spikes (ramp to N× baseline in seconds), not just steady load.
- Assert on **SLOs**: p95/p99 latency and error rate per endpoint; throughput at target
  concurrency; no overselling under the flash-sale scenario (functional + load combined).

## What to watch while loading
- The observability stack (traces, metrics): DB connection pool saturation, slow queries,
  cache hit rate, job queue depth, lock waits on stock rows.
- Confirm caching (caching.md) and queues (background-jobs.md) actually absorb the spike.

## When to run
- Before launch, before a known big campaign, and in CI as a periodic (not per-PR) job
  against staging. Record results to catch regressions over time.
