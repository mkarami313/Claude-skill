# 18 · Shifts & attendance

## Model
- `Shift`: scheduled work period for an employee (start/end, role, location).
- `Attendance`: clock-in/clock-out records (manual, or tied to POS register sessions 17),
  computed worked hours, lateness/overtime flags.
- `LeaveRequest`: time-off request with approval workflow and balance.

## Rules
- Tenant-scoped; managers approve leave and adjust attendance (permissioned, audited).
- Worked hours feed payroll (payroll-basics).
- Prevent overlapping shifts; enforce max hours rules if configured.

## API surface
- CRUD shifts/roster; clock in/out; attendance report; request/approve leave; leave balance.
