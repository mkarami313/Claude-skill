# Sample vertical slice — Catalog: create a product

One feature, all four layers, showing the canonical flow:
`ProductsController` (Api) → `CreateProductCommand` + handler + validator (Application) →
`Product` (Domain) → `ProductConfiguration` (Infrastructure/EF).

Read these together to see how a request travels and where each responsibility lives. Match
this shape for every new feature: thin controller, MediatR command, FluentValidation
validator, rich domain entity with a factory method, explicit EF mapping, `Result` outcomes,
DTOs in/out (never entities on the wire), optimistic concurrency via `xmin`.

Files:
- `Product.cs` — domain entity (tenant-owned) with a `Create` factory + a domain event.
- `CreateProduct.cs` — command, DTO, validator, and handler in one file for readability
  (in the real project, split one public type per file per the coding standard).
- `ProductConfiguration.cs` — EF Core mapping incl. tenant filter + concurrency token.
- `ProductsController.cs` — thin, versioned, authorized controller.
