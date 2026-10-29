# 05 · Wallet

An internal store-credit balance per customer, backed by an immutable ledger.

## Model
- `Wallet`: `Id`, `TenantId`, `CustomerId`, `Balance` (Money, derived), `Currency`.
- `WalletEntry` (append-only): `Amount` (signed), `Type` (TopUp | Payment | Refund |
  Cashback | Adjustment), `ReferenceType`+`ReferenceId`, `OccurredAtUtc`, `UserId`.
- `Balance` = Σ entries; keep a cached balance updated transactionally.

## Operations
- **Top-up:** customer pays via a gateway → on `PaymentVerified`, post a `TopUp` entry.
- **Pay:** use wallet at checkout → post a negative `Payment` entry; reject if insufficient.
- **Refund to wallet:** returns/refunds can credit the wallet (faster than gateway).
- **Cashback:** loyalty (10) credits via `Cashback` entries.
- **Adjustment:** staff correction, permissioned + audited.

## Rules
- Never allow negative balance; check-and-debit in one transaction (row lock).
- Every change is an entry — balance is always explainable.
- Feeds accounting (06) as a liability (customer-owed credit).

## API surface
- Get balance/history; top-up (creates payment); pay-with-wallet at checkout; staff adjust.
