# 05 · Gateway abstraction

One interface, many adapters. Adding a gateway must not touch the core.

## Contract
- `IPaymentGateway`:
  - `RequestPaymentAsync(context) → { RedirectUrl, GatewayReference }`
    where context = { amount (Money), orderId, callbackUrl, description, mobile }.
  - `VerifyAsync(verifyContext) → { Verified, PaidAmount, GatewayRef, RawStatus }`
    (server-to-server confirmation).
  - optional `RefundAsync(refundContext) → { Refunded, RefundRef }`.
- Each adapter is registered with a key (e.g. `zarinpal`, `idpay`, `payir`, `bank-direct`).

## Per-tenant configuration
- Tenant config (01) stores which gateway(s) are active and their **encrypted** credentials
  (merchant id / api key). Credentials never leave the server or appear in logs.
- Customer may choose among active gateways at checkout.

## Adapters to implement (behind the same interface)
- Iranian redirect gateways (e.g. ZarinPal, IDPay, Pay.ir) and direct bank/Shaparak PSPs.
- A `manual` pseudo-gateway for card-to-card / bank-receipt (needs staff confirmation).

## Rules
- All outbound calls allow-listed hosts, TLS-verified, timed out, retried safely.
- Map gateway-specific status codes into the common result; log raw status (no secrets).
