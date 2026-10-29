# 01 · Tenant configuration (white-label + feature flags)

Each tenant carries everything that makes its store look and behave uniquely.

## `Tenant` aggregate
- Identity: `Id`, `Slug`, status (active/suspended), plan.
- Domains: one or more hostnames (primary + custom), verification state.
- Branding: store name, logo, favicon, color palette, default locale & currency.
- Contact/legal: support channels, business/legal identifiers for invoices.

## Enabled modules (feature flags)
- A per-tenant set of enabled module keys (e.g. `marketplace`, `b2b`, `pos`, `loyalty`).
- Every optional feature checks its flag before executing; disabled → endpoints hidden
  (404/forbidden) and not advertised in the config endpoint.
- Changing flags publishes `TenantModulesChanged`.

## Provider selection (per tenant)
- Active adapters chosen per tenant: payment gateway(s) (05), SMS/email provider (15),
  shipping carriers (08), search engine config (12).
- Stored as references + encrypted credentials (secrets never returned to the frontend).

## Config endpoint
- `GET /api/v1/tenant/config` returns branding + enabled modules + public settings only
  (no secrets) for the headless frontend to render the white-label storefront.

## Provisioning
- Creating a tenant seeds defaults (roles, locale, currency, base pages) and publishes
  `TenantProvisioned`.
