# 13 · Vendor onboarding

## Model
- `Vendor`: `Id`, `TenantId`, business name, legal/tax IDs, contacts, bank/payout details
  (encrypted), commission profile, status (Pending | Approved | Suspended), rating.
- `VendorDocument`: uploaded verification docs (safe upload), review status.
- Vendor staff are users with vendor-scoped roles linked to the `Vendor`.

## Workflow
1. Apply (public form) → `Pending`.
2. Upload required documents.
3. Admin reviews → approve/reject (reason). `VendorApproved` on approval seeds the vendor
   panel access and default settings.
4. Suspend/reactivate as needed (hides vendor's listings).

## Rules
- Payout/bank details encrypted; never returned to the frontend.
- Document upload validated (V12); approvals permissioned + audited.

## API surface
- Apply; upload docs; admin review/approve/suspend; vendor profile management.
