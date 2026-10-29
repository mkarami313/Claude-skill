using Catalog.Domain;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Catalog.Infrastructure;

public sealed class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    private readonly ITenantContext _tenant;
    public ProductConfiguration(ITenantContext tenant) => _tenant = tenant;

    public void Configure(EntityTypeBuilder<Product> builder)
    {
        builder.ToTable("products", schema: "catalog");
        builder.HasKey(p => p.Id);

        builder.Property(p => p.Name).HasMaxLength(200).IsRequired();
        builder.Property(p => p.Slug).HasMaxLength(200).IsRequired();
        builder.HasIndex(p => new { p.TenantId, p.Slug }).IsUnique(); // slug unique per tenant

        // Money as an owned value object → two columns (amount + currency).
        builder.OwnsOne(p => p.Price, price =>
        {
            price.Property(m => m.Amount).HasColumnName("price_amount");
            price.Property(m => m.Currency).HasColumnName("price_currency").HasMaxLength(3);
        });

        // Optimistic concurrency via PostgreSQL system column xmin (locked strategy).
        builder.Property(p => p.Version).HasColumnName("xmin").IsRowVersion();

        // Tenant isolation: no query can see another tenant's rows.
        builder.HasQueryFilter(p => p.TenantId == _tenant.Current);
    }
}
