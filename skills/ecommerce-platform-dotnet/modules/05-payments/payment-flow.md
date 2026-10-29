# 05 · Payment flow (verified & idempotent)

Treat the customer's return from the gateway as **untrusted**. Trust only the server-to-server verify.

## `PaymentTransaction`
- `Id`, `TenantId`, `OrderId`, `Amount` (Money), `Status` (Pending | Verified | Failed |
  Refunded), `GatewayKey`, `GatewayReference`, `IdempotencyKey`, timestamps, raw status log.

## Steps
1. **Initiate:** create a `Pending` transaction for the order amount; call
   `RequestPaymentAsync`; store `GatewayReference`; redirect customer. Publish `PaymentInitiated`.
2. **Callback/return:** gateway redirects the user back AND/OR calls a webhook.
   - Look up the transaction by your own reference (not by client-sent amount/status).
   - Call `VerifyAsync` (server-to-server).
   - Confirm `Verified == true` AND `PaidAmount == transaction.Amount` AND the order is still
     `PendingPayment`.
   - In one DB transaction: mark `Verified`, mark order `Paid`, publish `PaymentVerified`.
3. **Idempotency:** ignore duplicate callbacks (same reference already verified → no-op).
4. **Failure/mismatch:** mark `Failed`, release reservations (03), publish `PaymentFailed`.

## Rules
- Never mark paid from the browser redirect alone.
- Amount mismatch, wrong order state, or failed verify ⇒ reject, no money state changes.
- Rate-limit and log all verify attempts; alert on anomalies.

## Tests
- Replayed callback → single paid state. Tampered amount/status → rejected. Verify-failure → failed.
