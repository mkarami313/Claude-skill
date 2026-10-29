using BuildingBlocks.Application;
using Catalog.Application.CreateProduct;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Catalog.Api;

[ApiController]
[Route("api/v1/catalog/products")]
[Authorize(Policy = "catalog.product.write")] // deny-by-default; explicit permission per endpoint
public sealed class ProductsController(ISender sender) : ControllerBase
{
    // Thin: bind DTO → send command → translate Result to HTTP. No business logic here.
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateProductCommand command, CancellationToken ct)
    {
        Result<Guid> result = await sender.Send(command, ct);

        return result.IsSuccess
            ? CreatedAtAction(nameof(GetById), new { id = result.Value }, new CreateProductResponse(result.Value))
            : Problem(title: result.Error.Code, detail: result.Error.Message, statusCode: StatusCodes.Status409Conflict);
    }

    [HttpGet("{id:guid}")]
    [Authorize(Policy = "catalog.product.read")]
    public Task<IActionResult> GetById(Guid id, CancellationToken ct) =>
        throw new NotImplementedException("Query handler omitted from the reference.");
}
