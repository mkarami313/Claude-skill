# Reference implementation — the style anchor

These files are the **canonical code style** for the whole platform. Before writing a new
module, skim the pieces relevant to your task and match their shape — naming, layering,
Result usage, tenant handling, validation, EF config, controller thinness. They are
illustrative (idiomatic .NET 10, trimmed for clarity), not a full compiling solution; don't
copy them verbatim, copy their *patterns*.

## What's here
- `cross-cutting/` — shared-kernel patterns every module reuses:
  - `Result.cs` — use-case outcome type (no exceptions for expected failures).
  - `Money.cs` — money value object (minor units + currency).
  - `BaseEntity.cs` — base entity + `ITenantEntity`.
  - `TenantSaveChangesInterceptor.cs` — auto-stamp `TenantId` + global filter wiring.
  - `ValidationBehavior.cs` — MediatR pipeline validation.
  - `OutboxMessage.cs` — transactional outbox record + dispatch sketch.
- `sample-module-catalog/` — one complete vertical slice (create a product) across all four
  layers, showing exactly how a feature flows Api → Application → Domain → Infrastructure.

## How to use
When implementing module N, read its `modules/N/` spec for *what*, and read these for *how*.
If a pattern here conflicts with a module spec, the module spec wins on behavior; these win
on style.
