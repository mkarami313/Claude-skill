# 25 · Impersonation, global search & bulk operations

## Customer impersonation (support)
- A permitted support agent can act "as" a customer to reproduce an issue.
- Issue a short-lived, clearly-flagged impersonation token that carries BOTH the real staff
  id and the impersonated customer id; every action logs the real actor.
- Scope it: read-focused by default; sensitive actions (change payment, place paid order)
  are blocked or require extra confirmation.
- Publish `ImpersonationStarted/Ended`; a hard time limit; fully audited (20). The customer
  may be notified per policy.

## Global search
- One admin search across orders, customers, products, tickets (delegates to each module /
  the search index 12), tenant-scoped, permission-filtered (results only from modules the
  staff can see).

## Bulk operations
- Admin-initiated batch actions (bulk price change, bulk status update, bulk export) run as
  Hangfire jobs (20) with progress + a per-item result report; idempotent; audited.
- Large destructive actions require confirmation and higher permission.

## Rules
- These are the highest-privilege paths in the system — least privilege, step-up auth where
  sensitive, and complete audit trails are mandatory.

## API surface
- Start/stop impersonation; global search; submit bulk operation + job status/report.
