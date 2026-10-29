# 09 · Support, reviews & Q&A

## Support tickets
- `Ticket`: `Id`, `TenantId`, `CustomerId`, subject, category, priority, status
  (Open | Pending | Answered | Closed), linked order (optional).
- `TicketMessage`: threaded messages with attachments (safe upload), author (customer/staff).
- Assignment to staff; SLA timers; internal notes separate from customer-visible messages.

## Reviews & ratings
- `Review`: product rating (1–5) + text, by a customer; `Status` (Pending | Approved |
  Rejected); optional "verified purchase" flag (only buyers can review, if configured);
  seller/staff reply.
- Moderation queue; profanity/spam checks; one review per customer per product (configurable).

## Product Q&A
- Public questions under a product with staff/community answers, moderated.

## Rules
- Customer-generated text is sanitized/encoded on output (XSS); attachments validated.
- Only the ticket owner or authorized staff can read a ticket (per-object authz).
- Reviews affect product rating aggregates and search ranking (12).

## API surface
- Create/reply ticket; list my tickets; staff queue + assign; submit review;
  moderate reviews; ask/answer product question.
