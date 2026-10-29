using FluentValidation;
using MediatR;

namespace BuildingBlocks.Application;

// MediatR pipeline behavior: runs all FluentValidation validators for a request before the
// handler. Register once; every command/query is validated centrally, so handlers assume
// valid input. Other behaviors to register similarly: logging, transaction/unit-of-work,
// and tenant-context enforcement.
public sealed class ValidationBehavior<TRequest, TResponse>(IEnumerable<IValidator<TRequest>> validators)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    public async Task<TResponse> Handle(
        TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        if (validators.Any())
        {
            var context = new ValidationContext<TRequest>(request);
            var failures = (await Task.WhenAll(validators.Select(v => v.ValidateAsync(context, ct))))
                .SelectMany(r => r.Errors)
                .Where(f => f is not null)
                .ToList();

            if (failures.Count != 0)
                throw new ValidationException(failures); // mapped to RFC 7807 400 centrally
        }
        return await next();
    }
}
