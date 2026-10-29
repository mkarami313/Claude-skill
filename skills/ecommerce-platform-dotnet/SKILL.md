---
name: ecommerce-platform-dotnet
description: >-
  Build or extend THIS multi-tenant (white-label) e-commerce platform backend in C# / .NET 10
  — a modular monolith following the locked stack and OWASP ASVS L2 security in this skill. Use
  it when implementing or changing any module of this store backend (catalog, inventory,
  ordering, payments, accounting, purchasing, shipping, customers/auth, marketing, content/SEO,
  search, marketplace, localization/tax, notifications, analytics, POS, HR, B2B, infra, AI),
  including when the user names a single module. A ROUTER over per-module folders: read this
  SKILL.md, then open only the target module's `_index.md` and the one or two sub-files needed,
  plus the security checklist — never all files at once. Do NOT use it for a different stack or
  an unrelated codebase, for frontend work, or for quick e-commerce Q&A (see "When NOT to use").
---

# E-commerce Platform — .NET 10 Backend Builder

A **modular, multi-tenant, white-label, API-only** store backend that any site can run on.
You implement it with Claude Code, one module at a time.

## How to use this skill (read every time)

Knowledge is split into small files on purpose — **do not read them all.** For a task:

1. Always read **`security/owasp-asvs.md`** — mandatory for every module.
2. Read **`standards/coding-standards.md`** once per session (build-wide rules).
3. **First time writing code this session**, skim **`reference-implementation/_index.md`** and
   the relevant canonical files — they are the style anchor for every module.
4. Find the module in the table below, open **`modules/<module>/_index.md`** first — it is
   the module's local map (scope, sub-files, integration events, Definition of Done).
5. From that `_index.md`, open **only** the sub-file(s) that cover your current task.
6. Before any **cross-module** work, read **`modules/00-architecture/data-map.md`**.
7. Read **`security/secure-dotnet-patterns.md`** whenever you touch auth, input, crypto,
   file upload, payments, or outbound calls.
8. Read the matching **`standards/`** file when relevant: `testing.md` (tests),
   `error-codes.md` (API errors / Result codes), `idempotency.md` (anything retryable —
   orders, payments, events, jobs, billing).

Each module is a folder broken into short sub-files (sub-modules) so no single file is large.
A cross-module task opens the two relevant `_index.md` files, not the whole tree.

## Scaffolding (start here on a fresh repo)
- `assets/scaffold/new-solution.sh` — create the solution skeleton + shared build files.
- `assets/scaffold/new-module.sh <Name>` — create one module's 4 projects + Contracts, wired.
Run these instead of hand-creating projects, so structure stays identical across modules.

## When NOT to use this skill

This skill imposes the locked stack below, so it is wrong for work that doesn't share it:
- A different stack (Node, Python, Java, PHP) or a different architecture — don't force these
  decisions onto someone else's project.
- An existing e-commerce codebase with its own conventions — follow that repo instead.
- Frontend / storefront UI work — this is backend only.
- A quick conceptual or comparison question about e-commerce — just answer it directly.
When in doubt, confirm the work is on *this* platform before applying the locked decisions.

## Locked technical decisions (do not re-decide)

| Area | Decision |
| --- | --- |
| Runtime | .NET 10, C# latest, `nullable` on, warnings-as-errors |
| API | ASP.NET Core, Controllers, REST, URL versioning (`/api/v1`) |
| Architecture | Modular monolith, Clean Architecture + DDD per module |
| Multi-tenancy | Shared DB + `TenantId`, EF global query filter |
| Database / ORM | PostgreSQL + EF Core (Dapper for heavy reads) |
| Concurrency | Optimistic concurrency via EF rowversion (`xmin` on Postgres) for stock, orders, wallet, ledger, counts — row locking only where a hard serialization point is needed |
| Auth | ASP.NET Identity + JWT access + rotating refresh; OTP via pluggable provider |
| Payments | Redirect gateways only — never store card data |
| Cache / jobs / logs | Redis, Hangfire, Serilog + OpenTelemetry |
| Search / vectors | OpenSearch (search) + pgvector (embeddings), behind `ISearchEngine`/`IEmbeddingProvider` so adapters are swappable, but OpenSearch + pgvector are the default build |
| Testing | xUnit + Testcontainers + Shouldly + NSubstitute + coverlet |
| Delivery | Docker + docker-compose, host-agnostic |
| Security target | OWASP Top 10 mitigated, OWASP ASVS Level 2 |
| Code language | Identifiers/comments English; user-facing strings localized |

## Module map — topic → folder

| Topic | Module folder |
| --- | --- |
| Project layout, module boundaries, building blocks | `modules/00-architecture/` |
| Tenant isolation, resolution, per-store config & feature flags | `modules/01-multitenancy/` |
| Products, variants, attributes, categories, brands, media | `modules/02-catalog/` |
| Warehouses, stock ledger, reservations, stocktaking, batches, valuation | `modules/03-inventory-warehouse/` |
| Cart, checkout, orders/OMS, returns/RMA, invoicing | `modules/04-ordering/` |
| Payment gateways, flow, wallet, refunds, installments | `modules/05-payments/` |
| Chart of accounts, ledger, invoices/VAT, AR/AP, financial reports | `modules/06-accounting/` |
| Suppliers, purchase orders, goods receipt, supplier payments | `modules/07-purchasing-suppliers/` |
| Shipping methods, zones/rates, fulfillment & tracking | `modules/08-shipping/` |
| Accounts, OTP auth, tokens, CRM, support, reviews | `modules/09-customers-auth/` |
| Discounts, promotions, loyalty, referral/affiliate, campaigns | `modules/10-marketing-loyalty/` |
| CMS, pages/blog, media, SEO metadata & schema, sitemap | `modules/11-content-seo/` |
| Search index, Persian queries, facets, recommendations | `modules/12-search/` |
| Multi-vendor onboarding, scoping, commission, settlement | `modules/13-marketplace/` |
| Languages/RTL, currencies, multi-store, tax/VAT | `modules/14-localization-tax/` |
| SMS/email/push, bot channels (Bale/Telegram), webhooks | `modules/15-notifications-channels/` |
| Dashboards, reports, funnels, exports, tracking | `modules/16-analytics/` |
| In-store POS: register sessions, sales, cash, offline sync | `modules/17-pos/` |
| Staff/HR: profiles, roles, shifts, payroll basics | `modules/18-hr/` |
| B2B wholesale: org accounts, price lists, quotes, credit | `modules/19-b2b-wholesale/` |
| API, webhooks, caching, jobs, messaging, observability, scaling, CI/CD, load testing | `modules/20-infrastructure/` |
| AI: semantic search, recommendations, chatbot, content, fraud | `modules/21-ai/` |
| Gift cards: issue, redeem, balance ledger | `modules/22-gift-cards/` |
| Subscriptions & recurring billing: plans, lifecycle, dunning | `modules/23-subscriptions/` |
| Data import & platform migration (WooCommerce etc.) | `modules/24-data-import/` |
| Admin/back-office: admin API, impersonation, bulk ops | `modules/25-admin-backoffice/` |
| Iran compliance: سامانه مؤدیان (Moadian), نماد اعتماد (E-Namad) | `modules/26-iran-compliance/` |

Cross-cutting references (not modules): `reference-implementation/` (code style anchor),
`standards/` (coding, testing, error-codes, idempotency), `security/`, `assets/` (build
files + scaffold scripts).

## Build order (phases)

- **Phase 1 — core:** 00 → 01 → 20 (skeleton) → 02 → 03 → 04 → 05 → 09 → 08 → 25 (admin surface)
- **Phase 2 — finance & growth:** 06 → 26 (Moadian/E-Namad) → 07 → 10 → 11 → 12 → 16 → 15
- **Phase 3 — scale & extend:** 13 → 14 → 22 → 23 → 24 → 17 → 18 → 19 → 21

Finish a module only when its `_index.md` Definition of Done and the security gate both pass.
