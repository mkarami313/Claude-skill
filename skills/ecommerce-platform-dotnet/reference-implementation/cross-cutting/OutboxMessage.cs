namespace BuildingBlocks.Infrastructure;

// Transactional outbox: integration events are written to this table in the SAME DB
// transaction as the state change, then a background dispatcher publishes them. Guarantees
// at-least-once delivery; consumers must be idempotent (dedupe by Id).
public sealed class OutboxMessage
{
    public Guid Id { get; init; } = Guid.CreateVersion7();
    public Guid TenantId { get; init; }
    public required string Type { get; init; }        // e.g. "Ordering.OrderPaid"
    public required string PayloadJson { get; init; }  // serialized event
    public DateTime OccurredAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime? ProcessedAtUtc { get; set; }
    public int Attempts { get; set; }
    public string? LastError { get; set; }
}

// Dispatcher sketch (runs as a Hangfire recurring job):
//   1. SELECT unprocessed messages (ProcessedAtUtc IS NULL) ORDER BY OccurredAtUtc, FOR UPDATE SKIP LOCKED.
//   2. For each: deserialize by Type, publish to the in-process bus (IIntegrationEventBus).
//   3. On success set ProcessedAtUtc; on failure increment Attempts + record LastError (retry with backoff).
//   4. Messages exceeding max attempts go to a dead-letter view + alert.
// Carry TenantId into the handler's context so consumers run tenant-scoped.
