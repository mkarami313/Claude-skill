# 20 · Messaging & integration events

How modules communicate asynchronously without coupling.

## Bus
- Start with an **in-process** event bus (MediatR notifications / a lightweight dispatcher)
  fed by the outbox; the `IIntegrationEventBus` abstraction lets you swap in a real broker
  (RabbitMQ) later when a module is extracted to its own service.
- Events are immutable records, versioned, past-tense (see 00 module-contracts for the list).

## Delivery semantics
- At-least-once via outbox; consumers idempotent (dedupe by event id).
- Ordering not guaranteed across types; handlers tolerate out-of-order (use timestamps/versions).
- Failed handlers retry (backoff) then dead-letter + alert; never block the publisher.

## Rules
- Events carry tenant id; handlers run in that tenant context.
- Keep payloads small (ids + essential data); consumers fetch details via contracts if needed.
- A new consumer must not require changes to the publisher.

## API surface
- Publish(event), Subscribe<T>(handler); event registry per module.
