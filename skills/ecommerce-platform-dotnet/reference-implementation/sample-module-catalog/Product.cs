using BuildingBlocks.Domain;

namespace Catalog.Domain;

public sealed class Product : BaseEntity, ITenantEntity
{
    private Product() { } // EF

    public Guid TenantId { get; private set; }
    public string Name { get; private set; } = null!;
    public string Slug { get; private set; } = null!;
    public ProductType Type { get; private set; }
    public Money Price { get; private set; }
    public ProductStatus Status { get; private set; }

    // Factory encodes invariants; callers can't construct an invalid Product.
    // TenantId is assigned by the SaveChanges interceptor, not passed in here.
    public static Product Create(string name, string slug, ProductType type, Money price)
    {
        var product = new Product
        {
            Name = name,
            Slug = slug,
            Type = type,
            Price = price,
            Status = ProductStatus.Draft,
        };
        product.Raise(new ProductCreated(product.Id));
        return product;
    }

    public void Activate() => Status = ProductStatus.Active;
}

public enum ProductType { Physical, Digital, Service, Subscription, Bundle }
public enum ProductStatus { Draft, Active, Archived }

public sealed record ProductCreated(Guid ProductId) : IDomainEvent;
