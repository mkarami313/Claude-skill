# 06 · Period close & external export

## Period close
- `AccountingPeriod`: month/quarter/fiscal year with status (Open | Closed).
- Closing a period: run checks (trial balance balances, subledgers reconcile, no unposted
  events), post adjusting entries (FX revaluation, accruals), then **lock** the period so no
  postings can change it.
- Reopening requires elevated permission and is audited.
- Fiscal year handling uses Jalali calendar where the tenant is Iranian (module 14).

## Export / integration to external accounting software
- Provide an `IAccountingExporter` abstraction with adapters per target
  (e.g. Sepidar, Hesabfa, Holoo) producing their import format (file or API).
- Export scope: journals, invoices, AR/AP, or a standard CSV/Excel for manual import.
- Map internal accounts → the external chart via a configurable mapping.
- Mark exported entries to avoid duplicates; support re-export of a corrected range.

## Rules
- Exports are tenant-scoped and permissioned; credentials for API targets encrypted.
- Never block internal posting on an external system being unavailable (queue + retry).

## API surface
- Open/close/reopen period; run close checks; configure exporter + mapping;
  export range (download or push); export status.
