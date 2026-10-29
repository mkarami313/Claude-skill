# 04 · Returns / RMA

## Model
- `ReturnRequest`: `Id`, `OrderId`, `CustomerId`, selected lines + quantities, reason,
  `Status`, requested refund method (gateway or wallet), timestamps, attachments (photos).
- Its own state machine: `Requested → Approved → ItemReceived → Refunded`
  (or `Rejected`).

## Workflow
1. Customer requests a return for eligible lines within the return window.
2. Staff review → approve/reject (reason required).
3. On item receipt: post inbound stock movement (03) — restock or quarantine (damaged),
   update serials/batches if tracked.
4. Issue refund (05) to the chosen method; publish `ReturnRefunded`;
   accounting (06) posts the reversal.

## Rules
- Eligibility: within window, line not already returned, order delivered (configurable).
- Refund amount is computed from the order snapshot (never client-supplied).
- Partial returns supported; track returned qty per line to prevent over-return.
- Permissioned approvals; full audit trail.

## API surface
- Create return request; get my returns; staff: review/approve/reject, mark received,
  issue refund.
