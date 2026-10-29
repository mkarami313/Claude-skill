# Module 18 · Staff & HR — index

Manages the people who run the store: staff accounts, what they can do, when they work, and
basic payroll. Optional (feature flag). Not a full HRMS — scoped to store operations.

## Scope
- Staff profiles (employees linked to user accounts).
- Roles & permissions management (the admin UI over RBAC from 09).
- Shifts & attendance.
- Payroll basics (hours → pay, feeding accounting 06).

## Sub-files
- `staff-profiles.md`, `roles-permissions.md`, `shifts-attendance.md`, `payroll-basics.md`.

## Integration events
- Publishes `StaffRoleChanged`; consumes register sessions (17) for hours if tied to shifts.

## Definition of done
- Staff can be created with scoped roles; shifts/attendance tracked; basic payroll computed
  and posted as an expense (06); all permissioned and audited.

## ASVS focus
- V4 (role/permission management is high-privilege), V8 (staff PII protection).
