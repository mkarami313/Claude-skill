using BuildingBlocks.Application;
using BuildingBlocks.Domain;
using Catalog.Domain;
using FluentValidation;
using MediatR;

namespace Catalog.Application.CreateProduct;

// NOTE: grouped in one file for the reference only. In the real project apply the standard:
// one public type per file.

public sealed record CreateProductCommand(string Name, string Slug, string Type, long PriceMinor, string Currency)
    : IRequest<Result<Guid>>;

public sealed record CreateProductResponse(Guid Id);

public sealed class CreateProductValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Slug).NotEmpty().Matches("^[a-z0-9-]+$");
        RuleFor(x => x.Type).Must(t => Enum.TryParse<ProductType>(t, out _));
        RuleFor(x => x.PriceMinor).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Currency).NotEmpty().Length(3);
    }
}

public sealed class CreateProductHandler(ICatalogDbContext db)
    : IRequestHandler<CreateProductCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateProductCommand cmd, CancellationToken ct)
    {
        // Expected failures → Result.Failure (not exceptions). Tenant filter makes this check tenant-scoped.
        var slugTaken = await db.Products.AnyAsync(p => p.Slug == cmd.Slug, ct);
        if (slugTaken)
            return Result.Failure<Guid>(Error.Conflict("product.slug_taken", "Slug already in use."));

        var product = Product.Create(
            cmd.Name, cmd.Slug, Enum.Parse<ProductType>(cmd.Type), new Money(cmd.PriceMinor, cmd.Currency));

        db.Products.Add(product);
        await db.SaveChangesAsync(ct); // interceptor stamps TenantId; outbox captures ProductCreated
        return Result.Success(product.Id);
    }
}
