namespace BuildingBlocks.Domain;

// Money is ALWAYS minor units (long) + currency. Never use float/double for money.
// Example: 125000 IRR → new Money(125000, "IRR"). Note IRR vs IRT (Toman) is a 10x trap;
// store one canonical unit (IRR recommended) and convert for display.
public readonly record struct Money(long Amount, string Currency)
{
    public static Money Zero(string currency) => new(0, currency);

    public Money Add(Money other)
    {
        EnsureSameCurrency(other);
        return this with { Amount = Amount + other.Amount };
    }

    public Money Subtract(Money other)
    {
        EnsureSameCurrency(other);
        return this with { Amount = Amount - other.Amount };
    }

    public Money Multiply(int quantity) => this with { Amount = Amount * quantity };

    private void EnsureSameCurrency(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException($"Currency mismatch: {Currency} vs {other.Currency}.");
    }
}
