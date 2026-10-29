# 00 · Module contracts & communication

Modules stay decoupled. They never reach into each other's internals.

## Two legal ways to communicate
1. **Synchronous, read-only query** via a published contract interface
   (e.g. `ICatalogQueries.GetProductSummary(id)`), exposed from `<Module>.Contracts`
   and implemented in that module's Infrastructure.
2. **Asynchronous integration events** published to `IIntegrationEventBus` after a
   transaction commits (via outbox). Other modules subscribe.

## Rules
- A module references another only through its `.Contracts` project.
- No shared mutable domain entities across modules; pass DTOs.
- Integration events are versioned, immutable records with past-tense names.
- A handler that fails must not break the publisher; handle retries idempotently.

## Core integration events (published by their owning module)
- `OrderPlaced`, `OrderPaid`, `OrderCancelled`, `OrderShipped` (04)
- `PaymentVerified`, `PaymentRefunded` (05)
- `StockReserved`, `StockReleased`, `StockAdjusted`, `LowStockReached` (03)
- `GoodsReceived` (07), `InvoiceIssued` (06)
- `CustomerRegistered`, `CartAbandoned` (09/04)
- `ProductChanged` (02) → consumed by search (12) to re-index

## Example subscriptions
- Accounting (06) subscribes to `OrderPaid`, `PaymentRefunded`, `GoodsReceived` to post journals.
- Notifications (15) subscribe to order/payment events to message the customer.
- Analytics (16) subscribe to most events to build reports.
