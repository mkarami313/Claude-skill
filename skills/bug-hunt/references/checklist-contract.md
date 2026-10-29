# Likely root causes — API ↔ React contract, Persian text, payments
Contract bugs: Area `contract` in the ledger; they belong to the backend module that owns the DTO.

## JSON contract
- Naming: PascalCase vs camelCase mismatch (custom `JsonSerializerOptions` on one endpoint, Newtonsoft on another).
- Enums: numbers on one side, strings on the other (`JsonStringEnumConverter` missing/added); new enum value unknown to the UI.
- `long` IDs / snowflake IDs > 2^53 lose precision in JS → serialize as string.
- Money as JSON number → float math in JS; send string or minor units (integer Rial).
- `DateTime` without offset/`Z` → browser shifts by +03:30; `DateOnly`/`TimeOnly` formats.
- Nullability: C# nullable vs TS optional differ; empty array vs `null`.
- Generated client (NSwag/orval/openapi) not regenerated after a DTO change; hand-written types drifted.
- Validation errors: ProblemDetails shape the UI doesn't read; 400 vs 422.
- Pagination/sorting params named differently; page index 0 vs 1.
- CORS with credentials (`AllowCredentials` + explicit origins); cookie `SameSite`; upload size limits (Kestrel + proxy).

## Persian text
- Arabic vs Persian letters: `ي`/`ی` and `ك`/`ک` → search misses, duplicate "unique" names/slugs. Normalize on write and on search.
- Persian/Arabic digits (`۰-۹`, `٠-٩`): `char.IsDigit` is true but `int.Parse` fails; phone/national code/OTP validation.
- ZWNJ (`‌`, نیم‌فاصله) breaks search, slugs, and equality.
- `CultureInfo("fa-IR")` uses PersianCalendar and its own number format, and differs between Windows (NLS) and Linux (ICU) → use `InvariantCulture` for anything machine-readable (parsing, storage, URLs, logs).
- Sorting/collation of Persian strings in DB vs in C#.

## Payment gateways (Iranian PSPs)
- **Rial vs Toman** (×10) mismatch between order, gateway request and verify.
- Callback trusted without server-side **verify**; verified amount not compared to the order amount.
- Verify not idempotent → double credit on callback retry or user refresh; no unique constraint on the gateway reference.
- Verify timeout/unknown result left as failed → needs a reconcile job (inquiry) before refund/cancel.
- Callback URL / order lookup not scoped by tenant; one merchant config used for all tenants.
- Stock reserved but never released when payment is abandoned.
