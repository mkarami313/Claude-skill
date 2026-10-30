---
name: iran-payments
description: Integrate, review or fix Iranian online payment gateways (IPG) — ZarinPal and Zibal, plus generic rules for any Iranian PSP. Use when adding a payment gateway, writing a payment request/callback/verify flow, handling Rial vs Toman amounts, making verify idempotent, reconciling unknown payments, or auditing existing payment code in a web app, bot or store backend (C#/.NET reference included).
---

# Iranian payment gateways (IPG)

Claude tends to get these wrong in the same ways: trusting the callback, guessing endpoints, mixing Rial and Toman, and crediting an order twice. This skill fixes the flow first; gateway details live in `references/` and are loaded only for the gateway in use.

## The flow (same for every gateway)
```
1. Create Payment row (Pending, amount in Rial, gateway, tenant)   ← BEFORE calling the gateway
2. POST request → gateway returns a token (ZarinPal: authority, Zibal: trackId)
3. Save the token on the row (unique index) → redirect the browser to the start page
4. User pays at the bank → gateway redirects to callbackUrl with the token
5. Callback: load the row BY TOKEN (not by session/cookie), then server-side VERIFY
6. Verify OK + amount matches → mark Paid and fulfil the order ONCE
```

## Non-negotiable rules
1. **The callback is a hint, never proof.** `Status=OK` or `success=1` in the query string is user-controlled. Only a server-side verify response decides.
2. **Amount comes from your DB.** Never read the amount from the callback query. ZarinPal verify takes the amount (mismatch → error -50); Zibal verify returns the amount — compare it to the stored amount yourself.
3. **One unit internally: Rial as `long`.** Convert only at the gateway boundary. Never `decimal`/`float` for the request amount. Name fields `AmountRial`, never just `Amount`. Send ZarinPal's `currency` explicitly (default is IRR). Zibal amounts are Rial.
4. **Verify is idempotent.** Callback can arrive twice (refresh, back button, retries). Use a conditional status transition (`UPDATE … SET Status='Verifying' WHERE Id=@id AND Status='Pending'`) or a row lock; only the winner calls verify and fulfils. "Already verified" codes (ZarinPal 101, Zibal 201) are success only if YOUR row is already Paid with the same token and amount — otherwise reconcile.
5. **Unknown ≠ failed.** Timeout, 5xx or network error during verify → status `Unknown`, not `Failed`. A background reconcile job resolves it with the gateway's inquiry endpoint. Never release stock or cancel an order while the payment is Unknown.
6. **Fulfil after commit.** Mark Paid and fulfil in one transaction (or outbox). Never send SMS/e-mail/bot messages before the commit succeeds.
7. **Callback endpoint is anonymous and tenant-aware.** The user's session may be gone after the bank redirect, and some banks return via POST (cross-site POST drops SameSite=Lax cookies). Look up by token; carry the tenant in the path (`/pay/callback/{tenant}/{gateway}`), not in the session.
8. **Per-tenant merchant credentials**, stored encrypted, never logged in full, never sent to the browser. The callback domain must match the domain registered with the gateway.
9. **Show the user a result page, not the verify JSON.** Show the bank reference (ZarinPal `ref_id`, Zibal `refNumber`), never a raw error code alone.
10. **Pending timeout.** Abandoned Pending payments expire (e.g. 30 min) via a job that also releases reserved stock — after one inquiry confirms they are not paid.

## Payment row — minimum fields
`Id · TenantId · OrderId · Gateway · AmountRial (long) · Status (Pending|Verifying|Paid|Failed|Unknown|Expired|Reversed) · Token (authority/trackId, unique per gateway) · RefId · CardPanMasked · CreatedAt · VerifiedAt · LastError · RawVerifyJson`

## Gateway references — load only the one you need
| Gateway | Reference | Notes |
|---|---|---|
| ZarinPal (REST v4) | `references/zarinpal.md` | Most common. Sandbox host available. |
| Zibal | `references/zibal.md` | Test merchant `zibal`. |
| Implementation in C#/.NET | `references/dotnet.md` | Entity, gateway interface, typed HttpClient, idempotent callback, reconcile job. |

**Other PSPs (IDPay, Pay.ir, PayPing, Vandar, bank IPGs like Saman/Mellat/Parsian):** apply the same rules, but **fetch the gateway's current official docs before writing code — never write endpoints or field names from memory.** If you cannot reach the docs, say so and ask the user for them. Check the gateway is still operating before integrating (some, e.g. IDPay, have had service and plugin-security problems).

## Review mode (auditing existing payment code)
Grep for the gateway calls and the callback action, then check, in order:
1. Callback trusts query `Status`/`success` without verify? → S0
2. Verify amount read from query/session instead of DB? → S0
3. Rial/Toman: same unit in order, request and verify? Hidden `*10` / `/10`? → S0
4. Double fulfilment possible (no status guard, no unique index on token)? → S0
5. Verify exception → order marked failed / stock released? → S1
6. Order lookup in callback not scoped to tenant, or one merchant id for all tenants? → S0 (multi-tenant)
7. Merchant id hard-coded or logged; sandbox flag on in production config? → S1
8. Fulfilment side effects before commit? → S2

Report each finding as `file:line — rule # — one-line fix`.

## When NOT to use
In-app purchases of Cafe Bazaar/Myket (different SDK flow), card-to-card receipts, and crypto payments.
