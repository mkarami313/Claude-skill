# Likely root causes — .NET backend (multi-tenant modular monolith)
Check the section that matches the symptom. Each item often explains many bugs at once.

## Tenant isolation (always S0)
- EF global query filter on `TenantId` missing for an entity, or bypassed by `IgnoreQueryFilters()`, raw SQL, `FromSql`, Dapper.
- Query filter captures the tenant at model build time (constant) instead of reading the scoped tenant property → every tenant sees the first one.
- Cache keys without the tenant (`IMemoryCache`, distributed cache, output cache, HybridCache).
- Background jobs, message handlers, hosted services run without a tenant context (new scope, tenant never set).
- Tenant resolved once and stored in a singleton or static.
- Files/blobs, search indexes, outgoing emails/SMS, SignalR groups not scoped by tenant.
- New entity saved without `TenantId` (no SaveChanges interceptor / default).

## DI and lifetimes
- Scoped service (DbContext, tenant context, current user) captured in a singleton → stale data, cross-tenant leaks. Enable `ValidateScopes`/`ValidateOnBuild` to surface them.
- `DbContext` used from parallel tasks (`Task.WhenAll` on one context) → "A second operation was started…".
- Module registration missing, or registered twice (two handlers; last wins / both run).
- `IOptions<T>` not validated (`ValidateOnStart`) → null config at runtime.

## Async
- `.Result` / `.Wait()` / `GetAwaiter().GetResult()` → deadlocks, thread-pool starvation.
- `async void`, un-awaited tasks (exceptions vanish), fire-and-forget using a disposed scope.
- `CancellationToken` not passed through → work continues after the request is aborted.
- Exception in a `BackgroundService` stops the host (.NET 8+ default `StopHost`) or kills the loop silently.

## EF Core
- N+1 (lazy loading, query inside a loop); missing `AsNoTracking` on read paths; tracking conflicts on update.
- `SaveChanges` inside a loop; several `SaveChanges` without a transaction → partial writes.
- No concurrency token on stock, balances, order state → lost updates.
- Model and migrations out of sync: `dotnet ef migrations has-pending-model-changes`.
- `decimal` without explicit precision → silent rounding/truncation.
- Client evaluation or `ToList()` before `Where` → whole table loaded.
- Cartesian explosion from multiple `Include` → use `AsSplitQuery`.

## Money and numbers
- `double`/`float` for money; rounding mode not explicit (`MidpointRounding.AwayFromZero` vs banker's default); tax per line vs per order; currencies mixed without conversion; discounts applied twice or in the wrong order.

## Time
- `DateTime.Now` instead of `UtcNow`/`TimeProvider`; `DateTimeKind.Unspecified` stored and read back as local.
- Persian (Solar Hijri) conversion at month/year boundaries, Esfand leap day; "end of day" computed in UTC instead of Iran time.
- Tests depending on the clock → inject `TimeProvider` (`FakeTimeProvider`).

## Validation and security (OWASP ASVS)
- Authorization on the endpoint but not on the resource's tenant/owner (IDOR).
- Over-posting: binding entities instead of DTOs (`TenantId`, `IsAdmin`, `Price` from the client).
- Middleware order: tenant resolution → `UseAuthentication` → `UseAuthorization`; CORS before auth; exception handler first.
- Secrets/PII in logs; stack traces in production responses.

## Infrastructure
- `new HttpClient()` per call → socket exhaustion; use `IHttpClientFactory`; missing timeouts/retries on gateways.
- Rate limiter or cache partitioned without tenant.
- Outbox/messages: handler not idempotent, duplicate delivery processes twice.
