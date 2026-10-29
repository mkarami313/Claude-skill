# 20 · Scaling & deployment

## Containerization
- Dockerfile per deployable (API host; optionally a separate worker for jobs).
- `docker-compose` for local/staging: API, worker, PostgreSQL, Redis, search engine, log sink.
- Config via environment variables / secret store; nothing secret in images or source.

## Scaling
- Stateless API → scale horizontally behind a load balancer; sessions/state in Redis/DB.
- Separate worker process for Hangfire so background load doesn't affect API latency.
- PostgreSQL: connection pooling, read replicas for heavy reads/reports, proper indexing.
- Handle spikes (flash sales): cache aggressively, queue heavy work, rate-limit, and
  pre-warm caches.

## Reliability
- Automated DB backups + tested restore (disaster recovery).
- Zero-downtime deploys (rolling); EF migrations applied safely (backward-compatible steps).
- Separate environments (dev/staging/prod); CI/CD runs build, analyzers, and tests before deploy.

## Host-agnostic
- Runs on any Docker host (cloud or on-prem in Iran); no hard cloud dependency —
  object storage, cache, and DB are configurable endpoints.

## API surface
- N/A (operational); provides Dockerfiles, compose, migration + health wiring.
