# Module 00 · Architecture — index

Defines how the whole solution is structured so every other module plugs in the same way.
A **modular monolith**: one deployable, internally split into isolated modules that can
later become services without a rewrite.

## Scope
- Solution/project layout and dependency direction.
- Shared building blocks (base entity, result type, tenant/user context, events).
- How modules talk to each other (contracts + integration events only).
- Global conventions wiring (MediatR, EF, validation pipeline).

## Sub-files (open what you need)
- `solution-layout.md` — folders, projects, per-module 4-layer template.
- `building-blocks.md` — shared kernel types to create first.
- `module-contracts.md` — cross-module communication rules + integration events.
- `data-map.md` — cross-module entity & event overview; read before any cross-module work.

## Integration events
- Publishes none itself; defines the event bus other modules use.

## Definition of done
- A new empty module is added by copying the 4-project template and registering it.
- Cross-module references compile only against contracts (enforced by project references).
- Domain layer has zero framework dependencies.

## ASVS focus
- V1 (architecture, trust boundaries, secrets never client-side).
