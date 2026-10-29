namespace BuildingBlocks.Domain;

public abstract class BaseEntity
{
    public Guid Id { get; protected set; } = Guid.CreateVersion7(); // sortable (time-ordered) key
    public DateTime CreatedAtUtc { get; protected set; } = DateTime.UtcNow;
    public DateTime? UpdatedAtUtc { get; protected set; }

    // Optimistic concurrency token. On PostgreSQL map to the system column xmin
    // (see EF config in the sample module). This is the LOCKED concurrency strategy.
    public uint Version { get; protected set; }

    private readonly List<IDomainEvent> _domainEvents = [];
    public IReadOnlyCollection<IDomainEvent> DomainEvents => _domainEvents.AsReadOnly();
    protected void Raise(IDomainEvent e) => _domainEvents.Add(e);
    public void ClearDomainEvents() => _domainEvents.Clear();
}

// Every tenant-owned entity implements this. TenantId is set by infrastructure, never by
// client input (see TenantSaveChangesInterceptor).
public interface ITenantEntity
{
    Guid TenantId { get; }
}

public interface IDomainEvent; // marker; concrete events are immutable records
