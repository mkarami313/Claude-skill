# 18 · Roles & permissions management

The management surface over the RBAC defined in module 09.

## Model
- `Role`: name, description, set of `Permission` keys; system roles (not deletable) +
  custom tenant roles.
- `Permission`: fine-grained keys per module/action (e.g. `catalog.product.edit`,
  `orders.refund`, `accounting.view`). Grouped by module for the admin UI.
- Assign roles to staff; a staff member may have several roles (union of permissions).

## Rules
- Deny by default; a permission absent means no access.
- Changing roles/permissions is itself a guarded permission; every change audited and
  publishes `StaffRoleChanged` (sessions re-evaluate on next token refresh).
- Scope assignments where relevant (e.g. warehouse-limited roles, vendor roles 13).
- Protect against privilege escalation: a user cannot grant permissions they lack.

## API surface
- CRUD roles; list permissions (grouped); assign/revoke roles; audit of role changes.
