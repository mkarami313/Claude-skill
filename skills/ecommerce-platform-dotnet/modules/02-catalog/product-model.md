# 02 · Product model

## `Product` aggregate
- `Id`, `TenantId`, `Name`, `Slug` (unique per tenant), `Description`, `ShortDescription`.
- `ProductType`: Physical | Digital | Service | Subscription | Bundle.
- `Status`: Draft | Active | Archived.
- Pricing: base `Price` (Money), optional `CompareAtPrice`; tax class (→ module 14).
- Flags per type (strategy-driven): `TracksStock`, `RequiresShipping`, `IsDownloadable`.
- SEO fields delegated to module 11 (title/meta/canonical) referenced by product.
- Brand (optional), categories (many), tags (many), attributes (see variants-attributes).

## Type behaviors (strategy)
- **Physical** — tracks stock (03), requires shipping (08).
- **Digital** — no shipping; delivers a file/license on `OrderPaid` (secure download link).
- **Service/bookable** — may need scheduling slots; no stock or capacity-based stock.
- **Subscription** — recurring billing plan (links to payments 05 recurring + orders 04).
- **Bundle** — composed of component products; price fixed or sum; stock derived from
  components.

## Rules
- Slug unique per tenant; validate on create/update.
- Price and tax class are server-authoritative; never trust client price at checkout (04).
- Archiving hides from storefront but preserves order history references.

## API surface (commands/queries)
- Create/Update/Archive product; Get product (admin) / Get product detail (storefront,
  tenant-filtered, only Active); List/search products (delegates filtering to module 12).
