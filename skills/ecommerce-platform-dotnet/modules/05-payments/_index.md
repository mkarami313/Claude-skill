# Module 05 · Payments & finance — index

Handles taking and returning money. **Redirect gateways only — card data is never stored.**
Built to support many gateways, chosen per tenant.

## Scope
- Pluggable gateway adapters (Iranian redirect gateways).
- Verified, idempotent payment flow.
- Internal wallet with a ledger.
- Refunds (full/partial).
- Installment / BNPL via third-party providers.

## Sub-files
- `gateway-abstraction.md` — the `IPaymentGateway` contract and adapters.
- `payment-flow.md` — request → redirect → verify → mark paid.
- `wallet.md` — balance, ledger, top-up/pay/cashback.
- `refunds.md` — refund to gateway or wallet.
- `installment-bnpl.md` — installment adapters.

## Integration events
- Publishes `PaymentInitiated`, `PaymentVerified`, `PaymentFailed`, `PaymentRefunded`.
- Consumes order placement (04); notifies accounting (06), ordering (04), notifications (15).

## Definition of done
- No payment is marked paid without a successful server-side verify; replayed/tampered
  callbacks are rejected (tested); every money change is ledgered; refunds reconcile.

## ASVS focus
- V8 (callback integrity), V9/SSRF (verify calls), V11 (amount checks), V7 (no secrets logged).
