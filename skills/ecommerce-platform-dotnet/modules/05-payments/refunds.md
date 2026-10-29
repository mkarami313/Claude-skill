# 05 · Refunds

## Model
- `Refund`: `Id`, `TenantId`, `OrderId`, `PaymentTransactionId`, `Amount` (Money),
  `Destination` (Gateway | Wallet), `Status` (Pending | Done | Failed), reason, timestamps.

## Flow
- Triggered by a return (04) or staff action.
- Amount derived from the order/return snapshot — never client-supplied.
- **To gateway:** call `RefundAsync` (if the adapter supports it) or create a manual payout
  task; confirm and record `RefundRef`.
- **To wallet:** post a `Refund` wallet entry immediately.
- On success: mark order `Refunded`/line returned, publish `PaymentRefunded`
  (accounting 06 posts the reversal; notifications 15 inform the customer).

## Rules
- Cannot refund more than captured (track refunded-to-date per transaction).
- Partial refunds supported and tracked per order line.
- Idempotent; permissioned; audited.

## API surface
- Create refund (staff/return handler); get refunds by order; retry failed gateway refund.
