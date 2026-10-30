# C# / .NET reference implementation

Target: ASP.NET Core + EF Core (.NET 8+). Adapt names to the project's conventions; keep the rules.

## Entity
```csharp
public enum PaymentStatus { Pending, Verifying, Paid, Failed, Unknown, Expired, Reversed }

public sealed class Payment
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid OrderId { get; set; }
    public string Gateway { get; set; } = "";          // "zarinpal" | "zibal"
    public long AmountRial { get; set; }               // the ONLY amount; never Toman
    public PaymentStatus Status { get; set; }
    public string? Token { get; set; }                 // authority / trackId (as string)
    public string? RefId { get; set; }
    public string? CardPanMasked { get; set; }
    public string? LastError { get; set; }
    public string? RawVerifyJson { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? VerifiedAt { get; set; }
}

// OnModelCreating
b.Entity<Payment>().HasIndex(p => new { p.Gateway, p.Token }).IsUnique().HasFilter("[Token] IS NOT NULL");
```
(`HasFilter` syntax is SQL Server; use `"\"Token\" IS NOT NULL"` on PostgreSQL.)

## Gateway abstraction
```csharp
public sealed record StartResult(bool Ok, string? Token, string? RedirectUrl, string? Error);

public enum VerifyOutcome { Paid, AlreadyPaid, Failed, Unknown }
public sealed record VerifyResult(VerifyOutcome Outcome, long? AmountRial, string? RefId,
                                  string? CardPan, string? Error, string RawJson);

public interface IPaymentGateway
{
    string Name { get; }
    Task<StartResult> StartAsync(Payment p, string callbackUrl, string description, GatewayCredentials creds, CancellationToken ct);
    Task<VerifyResult> VerifyAsync(Payment p, GatewayCredentials creds, CancellationToken ct);
    Task<VerifyResult> InquiryAsync(Payment p, GatewayCredentials creds, CancellationToken ct);
}

public sealed record GatewayCredentials(string MerchantId, bool Sandbox);   // per tenant, decrypted at use
```
Register gateways as typed `HttpClient`s with a short timeout (e.g. 15 s) and **no automatic retry on verify** (a retry after a lost response is fine only because verify is idempotent at the gateway — still, let the reconcile job do it).

## ZarinPal client (core of it)
```csharp
public sealed class ZarinPalGateway(HttpClient http) : IPaymentGateway
{
    public string Name => "zarinpal";
    static string Host(bool sandbox) => sandbox ? "https://sandbox.zarinpal.com" : "https://payment.zarinpal.com";

    public async Task<StartResult> StartAsync(Payment p, string callbackUrl, string description,
                                              GatewayCredentials c, CancellationToken ct)
    {
        var body = new { merchant_id = c.MerchantId, amount = p.AmountRial, currency = "IRR",
                         callback_url = callbackUrl, description,
                         metadata = new { order_id = p.OrderId.ToString() } };
        using var res = await http.PostAsJsonAsync($"{Host(c.Sandbox)}/pg/v4/payment/request.json", body, ct);
        var root = (await res.Content.ReadFromJsonAsync<JsonElement>(ct));
        if (TryData(root, out var data) && data.GetProperty("code").GetInt32() == 100)
        {
            var authority = data.GetProperty("authority").GetString()!;
            return new(true, authority, $"{Host(c.Sandbox)}/pg/StartPay/{authority}", null);
        }
        return new(false, null, null, ErrorText(root));
    }

    public async Task<VerifyResult> VerifyAsync(Payment p, GatewayCredentials c, CancellationToken ct)
    {
        string raw;
        try
        {
            var body = new { merchant_id = c.MerchantId, amount = p.AmountRial, authority = p.Token };
            using var res = await http.PostAsJsonAsync($"{Host(c.Sandbox)}/pg/v4/payment/verify.json", body, ct);
            raw = await res.Content.ReadAsStringAsync(ct);
            if ((int)res.StatusCode >= 500) return new(VerifyOutcome.Unknown, null, null, null, $"HTTP {(int)res.StatusCode}", raw);
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            return new(VerifyOutcome.Unknown, null, null, null, ex.Message, "");   // NOT Failed
        }

        var root = JsonDocument.Parse(raw).RootElement;
        if (TryData(root, out var d))
        {
            var code = d.GetProperty("code").GetInt32();
            var refId = d.TryGetProperty("ref_id", out var r) ? r.ToString() : null;
            var pan = d.TryGetProperty("card_pan", out var cp) ? cp.GetString() : null;
            if (code == 100) return new(VerifyOutcome.Paid, p.AmountRial, refId, pan, null, raw);
            if (code == 101) return new(VerifyOutcome.AlreadyPaid, p.AmountRial, refId, pan, null, raw);
        }
        return new(VerifyOutcome.Failed, null, null, null, ErrorText(root), raw);
    }

    public Task<VerifyResult> InquiryAsync(Payment p, GatewayCredentials c, CancellationToken ct)
        => throw new NotImplementedException("Call inquiry.json — confirm fields in ZarinPal docs first.");

    // data is an OBJECT on success and an empty ARRAY on error
    static bool TryData(JsonElement root, out JsonElement data) =>
        root.TryGetProperty("data", out data) && data.ValueKind == JsonValueKind.Object;

    static string ErrorText(JsonElement root) =>
        root.TryGetProperty("errors", out var e) && e.ValueKind == JsonValueKind.Object
            ? $"{e.GetProperty("code")}: {e.GetProperty("message").GetString()}"
            : "unknown error";
}
```
Zibal is the same shape: `merchant/amount/callbackUrl/description/orderId` → `trackId`, verify with `merchant/trackId`, and **set `AmountRial` in the result from the response's `amount`** so the caller compares it.

## Callback — idempotent
```csharp
[AllowAnonymous]
[IgnoreAntiforgeryToken]                       // the bank, not your form, may POST here
[AcceptVerbs("GET", "POST", Route = "/pay/callback/{tenant}/{gateway}")]
public async Task<IActionResult> Callback(string tenant, string gateway, CancellationToken ct)
{
    string Param(string k) => Request.Query.TryGetValue(k, out var q) ? q.ToString()
                            : Request.HasFormContentType ? Request.Form[k].ToString() : "";
    var token = gateway switch { "zarinpal" => Param("Authority"), "zibal" => Param("trackId"), _ => "" };
    var tenantId = await tenants.ResolveIdAsync(tenant, ct);
    var p = await db.Payments.AsNoTracking().SingleOrDefaultAsync(x => x.TenantId == tenantId && x.Gateway == gateway && x.Token == token, ct);
    if (p is null) return View("PaymentResult", PaymentResultVm.NotFound);
    if (p.Status == PaymentStatus.Paid) return View("PaymentResult", PaymentResultVm.From(p));   // refresh / double callback

    // Only one request wins the Pending → Verifying transition.
    var won = await db.Payments
        .Where(x => x.Id == p.Id && x.Status == PaymentStatus.Pending)
        .ExecuteUpdateAsync(s => s.SetProperty(x => x.Status, PaymentStatus.Verifying), ct) == 1;
    if (!won) return View("PaymentResult", PaymentResultVm.Processing);   // the other request is verifying

    var creds = await credentials.GetAsync(tenantId, gateway, ct);
    var r = await gateways[gateway].VerifyAsync(p, creds, ct);
    await payments.ApplyVerifyResultAsync(p.Id, r, ct);   // see below
    return View("PaymentResult", PaymentResultVm.From(await db.Payments.AsNoTracking().SingleAsync(x => x.Id == p.Id, ct)));
}
```

## Applying the result (shared by callback and reconcile job)
```csharp
public async Task ApplyVerifyResultAsync(Guid paymentId, VerifyResult r, CancellationToken ct)
{
    await using var tx = await db.Database.BeginTransactionAsync(ct);
    var p = await db.Payments.SingleAsync(x => x.Id == paymentId, ct);
    if (p.Status == PaymentStatus.Paid) return;                         // idempotent

    p.RawVerifyJson = r.RawJson;
    switch (r.Outcome)
    {
        case VerifyOutcome.Paid or VerifyOutcome.AlreadyPaid when r.AmountRial == p.AmountRial:
            p.Status = PaymentStatus.Paid; p.RefId = r.RefId; p.CardPanMasked = r.CardPan;
            p.VerifiedAt = clock.UtcNow;
            await orders.MarkPaidAsync(p.OrderId, ct);                   // must itself be idempotent
            outbox.Add(new PaymentSucceeded(p.Id, p.OrderId));           // SMS/e-mail/bot AFTER commit
            break;
        case VerifyOutcome.Paid or VerifyOutcome.AlreadyPaid:           // amount mismatch
            p.Status = PaymentStatus.Unknown; p.LastError = $"amount mismatch {r.AmountRial} != {p.AmountRial}";
            break;
        case VerifyOutcome.Unknown:
            p.Status = PaymentStatus.Unknown; p.LastError = r.Error;      // reconcile job picks it up
            break;
        default:
            p.Status = PaymentStatus.Failed; p.LastError = r.Error;
            break;
    }
    await db.SaveChangesAsync(ct);
    await tx.CommitAsync(ct);
}
```

## Reconcile job (hosted service, every few minutes)
- `Unknown` rows, and `Verifying` rows older than ~2 min (a crashed request) → `InquiryAsync` / `VerifyAsync` → `ApplyVerifyResultAsync`.
- `Pending` rows older than the expiry window → one inquiry; if not paid → `Expired` + release reserved stock.
- Rows still `Unknown` after N attempts → alert a human; never auto-cancel.

## Toman at the edges
If the catalog stores Toman, convert once: `long ToRial(long toman) => checked(toman * 10);`. Put the conversion in one helper with a unit test; grep for stray `* 10` / `/ 10` near payment code during review.

## Tests worth having
- Verify called twice concurrently → order paid once (`Task.WhenAll` on two callbacks).
- Verify throws `TaskCanceledException` → status `Unknown`, stock still reserved.
- ZarinPal error JSON with `"data": []` parses without exception.
- Zibal verify returns a different amount → not Paid.
- Callback for tenant A with a token of tenant B → NotFound.
