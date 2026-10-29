# 26 · نماد اعتماد الکترونیک (E-Namad trust seal)

E-Namad is the trust seal Iranian e-commerce sites display; obtaining it imposes requirements
the platform should make easy to satisfy. The platform doesn't "integrate" an API so much as
expose and enforce what E-Namad verification checks.

## What the platform must provide
- A verifiable **business/contact page**: legal owner, address, phone, support channels
  (served from tenant config 01 / CMS 11).
- Clear, accessible **policies**: terms, privacy, returns/refund, shipping — as CMS pages (11).
- The **seal placeholder**: a configurable slot to embed the E-Namad verification code/widget
  the storefront renders (the code is issued to the seller; store it in tenant config).
- Domain-ownership verification support: serve a verification file/meta tag the seller is
  asked to publish.
- Accurate pricing in IRR/Toman and a working, verifiable checkout + a real payment gateway
  (05) — E-Namad checks the purchase flow functions.

## Model
- Tenant config fields: E-Namad code, verification token/file, business legal details,
  policy page references, seal display settings.

## Rules
- Expose only public business data to the storefront; keep credentials private.
- Make the required policy pages part of tenant onboarding so a new store is seal-ready.

## API surface
- Get/set E-Namad config; serve verification file/meta; storefront endpoint returning the
  seal embed + business/contact data.
