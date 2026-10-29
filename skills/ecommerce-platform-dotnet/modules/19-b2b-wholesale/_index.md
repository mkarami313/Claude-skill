# Module 19 · B2B / wholesale — index

Selling to businesses, not just consumers: organization accounts, negotiated pricing,
quotes, and credit terms. Optional (feature flag).

## Scope
- Organization (company) accounts with multiple buyers and approval.
- Wholesale price lists & quantity tiers.
- Quotes / proforma and negotiated orders.
- Credit terms (buy now, pay on terms) with AR (06).

## Sub-files
- `org-accounts.md`, `price-lists-tiers.md`, `quotes-proforma.md`, `credit-terms.md`.

## Integration events
- Publishes `QuoteAccepted`, `CreditOrderPlaced`; feeds AR in accounting (06).

## Definition of done
- A company account with multiple buyers sees its negotiated prices; quotes convert to
  orders; credit orders create AR and respect credit limits; all tenant-scoped.

## ASVS focus
- V4 (org-scoped access), V11 (credit limit & pricing correctness).
