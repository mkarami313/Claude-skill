using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace BuildingBlocks.Infrastructure;

// Auto-stamps TenantId on insert from the trusted tenant context — the client can never set
// or change which tenant a row belongs to. Pair this with a GLOBAL QUERY FILTER in each
// DbContext so reads are tenant-scoped automatically.
public sealed class TenantSaveChangesInterceptor(ITenantContext tenant) : SaveChangesInterceptor
{
    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData, InterceptionResult<int> result, CancellationToken ct = default)
    {
        var context = eventData.Context;
        if (context is null) return base.SavingChangesAsync(eventData, result, ct);

        foreach (var entry in context.ChangeTracker.Entries<ITenantEntity>())
        {
            if (entry.State == EntityState.Added)
                entry.Property(nameof(ITenantEntity.TenantId)).CurrentValue = tenant.Current;
        }
        return base.SavingChangesAsync(eventData, result, ct);
    }
}

// In each DbContext.OnModelCreating, for every ITenantEntity type:
//   builder.Entity<T>().HasQueryFilter(e => e.TenantId == _tenant.Current);
//   builder.Entity<T>().Property<uint>("Version").IsRowVersion().HasColumnName("xmin");
// The filter guarantees no query crosses tenants; IgnoreQueryFilters() is allowed ONLY for
// vetted super-admin cross-tenant use cases.
