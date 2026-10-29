# 03 · Inventory valuation

Tracks the monetary value of stock and the cost of goods sold (COGS), feeding accounting (06).

## Costing method
- Default **Weighted Average Cost (WAC)**; support **FIFO** as an option per tenant/product.
- Each inbound movement carries `UnitCost`; WAC recalculates average on receipt:
  `newAvg = (onHandValue + receivedValue) / (onHand + receivedQty)`.
- Each outbound movement records COGS at the current method's cost (WAC: current average;
  FIFO: consume oldest layers). Store the computed cost on the movement for audit.

## Layers (FIFO)
- Maintain cost layers per variant/warehouse (qty + unitCost + date); consume oldest first;
  batch tracking (if enabled) aligns layers to batches.

## Outputs
- `InventoryValuationReport`: on-hand value per variant/warehouse/total at a date.
- COGS per sale → published so accounting (06) can post the COGS journal on `OrderShipped`.

## Rules
- Valuation updates transactionally with every movement.
- Negative stock (if backorder allowed) uses a provisional cost, reconciled on receipt.

## API surface
- Set costing method; get valuation report; get COGS for an order; cost-layer inspection.

## Links: feeds accounting (06) journals (inventory asset, COGS); cost source is purchasing (07).
