# 00 · Solution layout

```
src/
  BuildingBlocks/            # shared kernel (see building-blocks.md)
    BuildingBlocks.Domain
    BuildingBlocks.Application
    BuildingBlocks.Infrastructure
  Modules/
    <ModuleName>/            # every module = 4 projects, same shape:
      <ModuleName>.Domain          # entities, value objects, domain events, rules
      <ModuleName>.Application      # use cases (commands/queries), DTOs, interfaces, validators
      <ModuleName>.Infrastructure   # EF config, repositories, external adapters
      <ModuleName>.Api              # controllers, module DI registration
    <ModuleName>.Contracts   # PUBLIC: integration events + DTOs other modules may use
  Api/                       # composition host: wires all modules, auth, middleware, swagger
  Migrations/                # EF migrations (one DbContext per module or shared with schemas)
tests/
  <ModuleName>.UnitTests
  <ModuleName>.IntegrationTests
```

## Dependency direction (inward only)
- `Api → Application → Domain`
- `Infrastructure → Application` (implements its interfaces)
- Domain depends on nothing external. No EF, no ASP.NET in Domain.
- A module may reference another module's **`.Contracts`** only — never its Domain/Infra/Api.

## Database ownership
- Each module owns its tables; use a Postgres **schema per module** (e.g. `catalog.*`,
  `ordering.*`) for clear boundaries in the shared database.
- Each module has its own `DbContext` scoped to its schema.

## Host wiring
- The `Api` host project calls each module's `AddXModule(configuration)` and
  `UseXModule()` registration methods; modules never register globals directly.
