# 19 · Organization accounts

## Model
- `Organization`: company profile (legal name, tax id, addresses), assigned price list,
  credit terms, status, account manager.
- `OrgMember`: links customers (users) to an organization with a role (Buyer | Approver |
  Admin) and spending limits.
- Shared org address book and cost centers (optional).

## Rules
- Org members see org pricing and may share carts/order history per policy.
- **Purchase approval workflow:** orders above a buyer's limit route to an Approver before
  payment/credit.
- Tenant- and org-scoped access (per-object authz): a member sees only their org's data.

## API surface
- CRUD organizations; manage members/roles/limits; approval workflow; org order history.
