# ZarinPal — REST API v4

Official docs: https://www.zarinpal.com/docs/paymentGateway/connectToGateway — check them if anything here disagrees with the gateway's responses.

## Hosts
| | Production | Sandbox |
|---|---|---|
| API | `https://payment.zarinpal.com/pg/v4/payment/` | `https://sandbox.zarinpal.com/pg/v4/payment/` |
| Start page | `https://payment.zarinpal.com/pg/StartPay/{authority}` | `https://sandbox.zarinpal.com/pg/StartPay/{authority}` |

Older code uses `api.zarinpal.com/pg/v4/...` and `www.zarinpal.com/pg/StartPay/`; prefer the `payment.` host above. Keep host + sandbox flag in configuration, never in code.

All calls: `POST`, `Content-Type: application/json`, `Accept: application/json`.

## 1. Request — `request.json`
```json
{
  "merchant_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "amount": 1500000,
  "currency": "IRR",
  "callback_url": "https://shop.example.com/pay/callback/acme/zarinpal",
  "description": "Order #10234",
  "metadata": { "mobile": "09121234567", "email": "a@b.com", "order_id": "10234" }
}
```
- `description` and `callback_url` are **required**.
- `currency`: `IRR` (Rial, **default**) or `IRT` (Toman). Always send it explicitly; this skill's rule is IRR.
- There is a minimum amount (SDK docs: 10,000 IRR); validate before calling.
- `metadata.auto_verify` (true/false) overrides the panel's auto-verify setting. Even with auto-verify, still call verify on callback — it is how you learn the result.

Success response:
```json
{ "data": { "code": 100, "message": "Success", "authority": "A0000000000000000000000000000wwOGYpd", "fee_type": "Merchant", "fee": 100 }, "errors": [] }
```
Redirect the browser to `StartPay/{authority}`. Save `authority` first.

## 2. Callback
GET to your `callback_url` with query `Authority=<authority>&Status=OK|NOK`.
- `NOK` → user cancelled or bank failed. You may mark Failed without verify, but a verify call is harmless and confirms it.
- `OK` → **verify** (never trust it alone).

## 3. Verify — `verify.json`
```json
{ "merchant_id": "…", "amount": 1500000, "authority": "A000…" }
```
`amount` is the one **stored on your payment row**, in the same unit (and currency) as the request.

Success:
```json
{ "data": { "code": 100, "message": "Verified", "card_hash": "…", "card_pan": "502229******5995", "ref_id": 201, "fee_type": "Merchant", "fee": 0 }, "errors": [] }
```
| code | Meaning | Action |
|---|---|---|
| 100 | Verified now | Mark Paid, store `ref_id`, `card_pan`, fulfil |
| 101 | Already verified earlier | Success **only if** your row is already Paid for this authority; otherwise treat as Paid and run fulfilment idempotently (a previous attempt crashed after verify) |
| other / `errors` set | Failed or invalid | See below |

## Errors
On failure the shape flips: `"data": []` (empty **array**) and `"errors": { "code": -51, "message": "…", "validations": [] }`.
**Deserialization trap:** `data` is an object on success but an array on error, and `errors` is an array on success but an object on error. Parse with `JsonElement`/`JsonNode` and check `ValueKind`; a strongly typed DTO will throw on one of the two shapes.

Common codes (full list: https://www.zarinpal.com/docs/paymentGateway/errorList):
| code | Meaning |
|---|---|
| -9 | Validation error (bad field; read `validations`) |
| -10 / -11 | Merchant id or IP/terminal problem; merchant inactive |
| -50 | Verify amount differs from the paid amount → **do not retry with another amount**; investigate |
| -51 | Payment failed / not paid → Failed |
| -54 | Invalid authority |
| -63 | Reverse window (30 min) expired |

## Other endpoints (same base path; confirm request fields in the docs before using)
- `inquiry.json` — status of an authority; use in the reconcile job for `Unknown` payments.
- `unVerified.json` — paid but not yet verified transactions; useful for a nightly sweep.
- `reverse.json` — refund a verified payment, allowed only within ~30 minutes and with restrictions; not a general refund API.
