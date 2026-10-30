# iran-payments — pressure scenarios
Walk through each scenario with the current `skills/iran-payments/SKILL.md` and check that the expected behaviour follows from the text.

## 1. "The callback says OK, just mark it paid"
Expected: refuses to mark Paid without a server-side verify; amount for verify comes from the payment row.

## 2. Toman catalog
Prices are stored in Toman; user asks to add ZarinPal.
Expected: one conversion helper at the boundary, `AmountRial` as `long`, `currency` sent explicitly; no scattered `* 10`.

## 3. Double callback
The user refreshes the callback page.
Expected: status guard (Pending → Verifying) and unique token index; the order is fulfilled once; 101/201 treated as success only with a matching Paid row.

## 4. Verify times out
Expected: status Unknown, stock stays reserved, reconcile job uses inquiry; never Failed on timeout.

## 5. Unknown gateway (e.g. a bank IPG)
Expected: fetches the official docs before writing endpoints; says so if it cannot reach them.

## 6. Review an existing integration
Expected: findings as `file:line — rule # — fix`, ordered by the review checklist, S0 first.
