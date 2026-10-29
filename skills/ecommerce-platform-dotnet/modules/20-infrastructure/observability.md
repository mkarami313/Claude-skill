# 20 · Observability

## Logging (Serilog)
- Structured JSON logs with correlation id, tenant id, user id (not PII), request path.
- Log levels disciplined; **never log** passwords, OTPs, tokens, card data, full PII, secrets.
- Centralize logs (e.g. to a log sink/ELK/Seq); retain per policy.

## Tracing & metrics (OpenTelemetry)
- Distributed tracing across HTTP, DB, cache, jobs, and outbound calls.
- Metrics: request rate/latency/errors, DB and cache timings, job queue depth, payment
  success/verify rates, checkout conversion — exportable to Prometheus/OTLP.

## Auditing
- Separate, tamper-evident audit log for security-relevant actions (auth, authz failures,
  role changes, refunds, price/stock edits, exports) — who/what/when, append-only.

## Health & alerting
- Liveness/readiness endpoints; dependency health (DB, Redis, search, providers).
- Alerts on error spikes, auth-failure spikes, payment anomalies, job backlogs.

## API surface
- Logging/tracing middleware; audit service; health-check endpoints; metrics exporter.
