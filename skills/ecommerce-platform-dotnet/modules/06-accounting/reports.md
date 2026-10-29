# 06 · Financial reports

All reports are tenant-scoped and derived from the ledger (single source of truth).

## Core statements
- **Trial balance** — all accounts with debit/credit balances for a period; must balance.
- **Profit & loss** — revenue − COGS − expenses for a period; gross and net margin.
- **Balance sheet** — assets = liabilities + equity as-of a date.
- **General ledger / account detail** — all postings per account with running balance.

## Operational finance reports
- VAT report — output VAT (sales) vs input VAT (purchases) for the filing period.
- AR/AP aging and statements (see ar-ap.md).
- Sales vs COGS vs margin by period/category (crosses analytics module 16).
- Payment-fee and discount expense summaries.

## Rules
- Compute from posted entries only; exclude drafts.
- Heavy reports run as background jobs and cache results (20); support as-of dating.
- Exportable to Excel/CSV/PDF.

## API surface
- Generate each report for a date range; export; VAT filing summary.
