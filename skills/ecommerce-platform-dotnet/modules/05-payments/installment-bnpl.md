# 05 · Installment / BNPL

Offer "buy now, pay later" or installments through third-party providers — same gateway shape.

## Model
- `InstallmentProvider` adapter implements `IPaymentGateway` (request/verify) plus
  provider-specific eligibility and plan selection.
- `InstallmentPlan` (informational): provider, number of installments, schedule — the
  provider owns collection; the store is paid upfront or per settlement terms.

## Flow
- At checkout, if the tenant enabled a BNPL provider and the cart is eligible, show it as a
  payment option.
- Redirect to the provider; verify server-to-server exactly like a normal gateway;
  on success mark the order paid (store receives funds per the provider agreement).

## Rules
- Eligibility (min/max amount, customer checks) enforced before offering.
- Never store the customer's credit terms/PII beyond what's needed; rely on the provider.
- Reconcile provider settlements in accounting (06).

## API surface
- Check BNPL eligibility for a cart; initiate BNPL payment; handle verify/callback.
