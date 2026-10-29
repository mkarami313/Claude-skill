# 18 · Staff profiles

## Model
- `Employee`: `Id`, `TenantId`, linked `UserId`, name, national/employee id, contact,
  position/title, assigned warehouse/store, employment type, hire date, status
  (Active | OnLeave | Terminated), compensation reference (payroll).
- Documents (contract, ID) with safe upload (V12).

## Rules
- Tenant-scoped; managing staff is a high-privilege, permissioned action.
- Staff PII is sensitive — encrypt at rest, minimize exposure, audit access.
- Deactivating an employee disables their user account/sessions (09).

## API surface
- CRUD employees; assign to warehouse/store; manage documents; deactivate.
