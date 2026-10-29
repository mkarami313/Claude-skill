# 00 · Building blocks (shared kernel — create these first)

Minimal cross-cutting types every module reuses. Keep them free of business logic.

## Domain primitives
- `BaseEntity` — `Id` (Guid v7 / ULID for sortable keys), `CreatedAtUtc`, `UpdatedAtUtc`.
- `ITenantEntity` — `Guid TenantId` (applied by multi-tenancy, module 01).
- `IAuditable` — created/updated by user id.
- `ValueObject` base (equality by components) for Money, Address, etc.
- `Money` value object — minor units (long) + currency code; never floating point.
- `IDomainEvent` + an entity-level `RaiseDomainEvent` collection.

## Application primitives
- `Result` / `Result<T>` — success/failure with error code + message; use cases return this
  instead of throwing for expected failures.
- `Error` — stable `Code` + safe `Message` (localizable key).
- `ICommand`, `IQuery<T>`, handlers via MediatR.
- Pipeline behaviors: validation (FluentValidation), logging, transaction, and
  tenant-context enforcement.
- `ICurrentUser` (id, roles, tenant), `ITenantContext` (current tenant).

## Infrastructure primitives
- `IUnitOfWork` / `SaveChanges` that dispatches domain events after commit.
- `IIntegrationEventBus` — in-process publish/subscribe for cross-module events
  (swappable for a real broker later).
- `IDateTime`, `IGuidGenerator` abstractions for testability.
- Outbox table + dispatcher for reliable integration-event delivery.

## Error handling
- One exception-handling middleware maps exceptions and failed `Result`s to RFC 7807
  Problem Details; details hidden in production (see security).
