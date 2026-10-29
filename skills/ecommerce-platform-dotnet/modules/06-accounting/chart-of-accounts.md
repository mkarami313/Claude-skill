# 06 · Chart of accounts

## Model
- `Account`: `Id`, `TenantId`, `Code`, `Name`, `Type` (Asset | Liability | Equity |
  Revenue | Expense), `ParentId` (tree), `IsPostable`, `Currency`, active flag.
- Hierarchical; only leaf (postable) accounts receive journal lines.

## Seeded default accounts (per tenant, editable)
- Assets: Cash/Bank, Gateway Receivable (in-transit), Inventory, Accounts Receivable.
- Liabilities: Accounts Payable, VAT Payable, Customer Wallet/Credit, Vendor Payable (13),
  Gift/Loyalty Liability.
- Revenue: Sales, Shipping Income.
- Expenses: COGS, Payment Fees, Discounts/Promotions, Shipping Expense.

## Rules
- Codes unique per tenant; mapping table links domain events → account codes so posting is
  configurable without code changes.
- Account mapping is validated at startup (every event type resolves to real accounts).
- Multi-currency accounts store amounts in account currency + tenant base currency.

## API surface
- CRUD accounts; manage event→account mapping; import a standard chart template.
