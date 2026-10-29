# 18 · Payroll basics

Lightweight payroll — enough to run store staff pay and post it to accounting. Not a full
statutory payroll engine; integrate with specialized payroll for complex cases.

## Model
- `CompensationPlan`: per employee — base salary or hourly rate, allowances.
- `PayrollRun`: a period; computes gross from salary or (hours × rate + overtime) using
  attendance, applies configured deductions, yields net pay per employee.
- `Payslip`: per employee per run (gross, deductions, net), downloadable.

## Rules
- Period-based; permissioned and audited (sensitive data).
- On finalize, publish an expense so accounting (06) posts Dr Salaries Expense, Cr Bank/Payable.
- Compensation data is highly sensitive PII — encrypt, restrict, audit access.
- Country-specific tax/insurance is out of scope here; expose hooks or export for a
  dedicated payroll system.

## API surface
- Manage compensation; create/compute/finalize payroll run; generate payslips; export.
