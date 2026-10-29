# 19 · Credit terms (pay on account)

Let trusted organizations order now and pay later on terms, tracked as AR.

## Model
- `CreditAccount` (per organization): credit limit, available credit, payment terms
  (e.g. net 30), status (Active | OnHold).
- Credit orders bypass upfront gateway payment and create an AR entry (06).

## Workflow
- At checkout, a credit-eligible org can choose "pay on terms" if within available credit.
- Placing the order reduces available credit, creates the order (04) as credit-approved,
  and posts an AR receivable (06); publishes `CreditOrderPlaced`.
- Payment later settles the AR (06) and restores available credit.
- Overdue invoices → dunning (15), possible account hold.

## Rules
- Enforce credit limit server-side; reject/route-to-approval when exceeded.
- Terms, limits, and holds are permissioned and audited.
- Statements and aging via AR (06).

## API surface
- Set/adjust credit limit & terms; check available credit; place credit order; statement.
