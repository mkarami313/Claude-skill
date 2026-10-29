# Module 25 · Admin / back-office — index

The staff-facing concerns that cut across every module: a coherent admin API surface, plus
admin-only behaviors that don't belong to any single domain module. This module doesn't
re-implement features — it aggregates and governs the staff view of them.

## Scope
- Admin API conventions (how back-office endpoints are shaped, listed, filtered, paged).
- Cross-module admin dashboard composition (pulls from analytics 16, orders, inventory…).
- Admin-only actions: customer impersonation (support), global search, bulk operations.
- Admin audit surfacing (reads the audit log from observability, 20).

## Sub-files
- `admin-api.md` — conventions + cross-module composition.
- `impersonation-bulk.md` — impersonation, global search, bulk ops.

## Integration events
- Consumes events to build admin read models; publishes `ImpersonationStarted/Ended`,
  `BulkOperationCompleted`.

## Definition of done
- Staff use a consistent admin API (list/filter/paginate/export) across modules; a support
  agent can safely impersonate a customer with full audit; bulk operations run as jobs with
  a report; everything is permission-gated (RBAC from 09/18) and audited.

## ASVS focus
- V4 (high-privilege actions, least privilege), V8 (impersonation fully audited), V13 (admin API authz).
