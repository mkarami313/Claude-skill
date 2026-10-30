# Zibal — IPG API v1

Official docs: https://help.zibal.ir/IPG/API/ — check them if anything here disagrees with the gateway's responses.

## Hosts
- API: `https://gateway.zibal.ir/v1/`
- Start page: `https://gateway.zibal.ir/start/{trackId}`
- **Testing:** use merchant `zibal`; transactions are simulated, no real money moves. There is no separate sandbox host.

All calls: `POST`, JSON body.

## 1. Request — `/v1/request`
```json
{
  "merchant": "your-merchant-code",
  "amount": 1500000,
  "callbackUrl": "https://shop.example.com/pay/callback/acme/zibal",
  "description": "Order #10234",
  "orderId": "10234",
  "mobile": "09121234567"
}
```
- `amount` is in **Rial**.
- camelCase field names (unlike ZarinPal's snake_case).

Response:
```json
{ "trackId": 3714061627, "result": 100, "message": "success" }
```
`result == 100` → save `trackId` (a **64-bit integer** — use `long`, and string in JSON sent to JS) and redirect to `start/{trackId}`. Any other `result` → fail with `message`.

## 2. Callback
GET to `callbackUrl` with query including `trackId`, `success` (1/0), `status` and `orderId`.
`success=1` is only a hint. Load the row by `trackId` and **verify**.

## 3. Verify — `/v1/verify`
```json
{ "merchant": "your-merchant-code", "trackId": 3714061627 }
```
Note: verify does **not** take the amount. The response returns it — **compare `amount` to `AmountRial` on your row**; mismatch → do not fulfil, flag for review.

Response (success) includes: `result`, `message`, `amount`, `refNumber`, `cardNumber` (masked), `paidAt`, `orderId`, `status`, `description`.

| result | Meaning | Action |
|---|---|---|
| 100 | Verified now | Compare amount → mark Paid, store `refNumber`, `cardNumber` |
| 201 | Already verified | Same handling as ZarinPal 101 (idempotent fulfilment) |
| other | Failed / not paid / invalid | Failed, store `message` |

## Other endpoints
- `/v1/inquiry` (`merchant`, `trackId`) — current status of a transaction; use it in the reconcile job for `Unknown` payments.
- Zibal also offers "lazy" (deferred) verification and other services — fetch the docs before using them.
