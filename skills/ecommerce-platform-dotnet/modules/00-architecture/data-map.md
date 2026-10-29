# 00 · Data map (cross-module entity & event overview)

Read this to see how modules' data relates before implementing anything cross-module. Each
module owns its own tables (schema per module); references across modules are by **id only**,
never FK across schemas. Modules coordinate by integration events, not shared tables.

## Core aggregates by module (owner → key entities)
- 01 multitenancy → `Tenant`, `Store`
- 02 catalog → `Product`, `ProductVariant`, `Category`, `Brand`, `AttributeDefinition`
- 03 inventory → `Warehouse`, `StockItem`, `StockMovement`, `Batch`, `Serial`
- 04 ordering → `Cart`, `Order`, `OrderLine`, `ReturnRequest`, `Invoice`
- 05 payments → `PaymentTransaction`, `Wallet`, `WalletEntry`, `Refund`
- 06 accounting → `Account`, `JournalEntry`, `ReceivableEntry`, `PayableEntry`
- 07 purchasing → `Supplier`, `PurchaseOrder`, `GoodsReceipt`, `SupplierInvoice`
- 08 shipping → `Shipment`, `ShippingZone`, `ShippingRate`
- 09 customers → `Customer`, `Address`, `Ticket`, `Review`
- 10 marketing → `Coupon`, `Promotion`, `LoyaltyAccount`, `Affiliate`
- 13 marketplace → `Vendor`, `VendorOffer`, `Settlement`
- 14 localization → `Locale`, `Currency`, `TaxRate`
- 22 gift-cards → `GiftCard`, `GiftCardTransaction`
- 23 subscriptions → `SubscriptionPlan`, `Subscription`, `BillingCycle`
- 26 iran-compliance → `MoadianInvoice`

## Reference-by-id links (not foreign keys)
`OrderLine.VariantId → catalog`; `Order.CustomerId → customers`; `StockMovement.ReferenceId →
order/PO/transfer`; `JournalEntry.SourceId → the event's document`; `VendorOffer.ProductId →
catalog`; `Subscription.CustomerId → customers`.

## Integration-event flow (publisher → consumers)
- `OrderPlaced` (04) → inventory reserve (03), analytics (16)
- `OrderPaid` (04) → accounting sales journal (06), notifications (15), loyalty (10), shipping (08), moadian (26)
- `OrderShipped` (04/08) → inventory commit + COGS (03/06)
- `PaymentVerified` (05) → ordering mark-paid (04); `PaymentRefunded` → accounting reversal (06)
- `StockAdjusted`/`ProductChanged` (03/02) → search reindex (12)
- `GoodsReceiptPosted` (07) → inventory inbound (03), accounts payable (06)
- `GiftCardRedeemed` (22) → ordering (04), accounting liability (06)
- `SubscriptionRenewed` (23) → ordering/payments (04/05), accounting (06)

Keep this file updated when a module adds an aggregate or event (it is the single overview).
See `module-contracts.md` for the communication rules themselves.
