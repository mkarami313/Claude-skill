# Module 20 · Infrastructure & platform — index

The technical backbone every module relies on. Build the skeleton early (phase 1).

## Scope
- API surface, versioning, docs.
- Caching (Redis).
- Background jobs (Hangfire) + outbox.
- Messaging / integration events.
- Observability (Serilog + OpenTelemetry).
- Scaling & deployment (Docker).
- CI/CD pipeline and load/performance testing.

## Sub-files
- `api-versioning.md`, `caching.md`, `background-jobs.md`, `messaging-events.md`,
  `observability.md`, `scaling-deploy.md`, `ci-cd.md`, `load-testing.md`.

## Definition of done
- Versioned API with OpenAPI docs; Redis cache; reliable jobs + outbox event delivery;
  structured logs + traces + metrics; containerized, horizontally scalable deployment;
  CI/CD enforcing the quality + security gates; hot paths load-tested against SLOs.

## ASVS focus
- V1/V5/V9 (secure config, headers, TLS), V7 (logging), V13 (API rate limits, authz).
