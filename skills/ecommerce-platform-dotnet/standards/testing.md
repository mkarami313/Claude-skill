# Testing standards (read when writing tests)

Tests are part of "done", not an afterthought. Focus effort on domain rules and security.

## Stack (locked)
- **xUnit** for unit + integration tests.
- **Testcontainers** to spin up real PostgreSQL (and Redis) for integration tests —
  no in-memory provider for data-layer tests, it hides real SQL behavior.
- **Shouldly** for readable asserts (free/open source — avoids FluentAssertions v8+, which
  requires a paid commercial license).
- **NSubstitute** for test doubles (single choice — don't mix mocking libraries).
- **coverlet** (`coverlet.collector`) for coverage.

## What to test (priority order)
1. **Domain rules** — pricing, discount limits, stock reservation, order state machine.
2. **Security behavior** — authorization denials, tenant isolation (a tenant cannot read
   another tenant's data), payment-callback tampering is rejected, OTP lockout.
3. **Application use cases** — command/query handlers with validation.
4. **Integration** — EF mappings, global query filters, migrations apply cleanly.

## Patterns
- Arrange-Act-Assert; one behavior per test; descriptive names
  (`Checkout_WithTamperedTotal_IsRejected`).
- For multi-tenancy, seed two tenants and assert cross-tenant access returns not-found.
- Make payment/notification providers interfaces so they can be faked in tests.
- Run tests in CI on every push; collect coverage with coverlet.

## Coverage gate (measurable)
- Measure line + branch coverage per project with coverlet; fail CI if the **Domain** and
  **Application** projects fall below **80%** (tune per team, but keep a concrete number —
  a vague "no coverage drop" gate is unenforceable).
- Don't chase coverage on Infrastructure/Api glue; the number targets core logic.

## Definition of done for tests
- Core domain logic and every security gate from `security/owasp-asvs.md` have tests.
- Integration tests run against containerized Postgres and pass from a clean DB.
- Coverage gate passes in CI.
