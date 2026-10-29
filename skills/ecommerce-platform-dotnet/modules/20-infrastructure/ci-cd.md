# 20 · CI/CD pipeline

A concrete pipeline so quality/security gates are enforced automatically, not by hope.

## CI (on every push / PR) — fail the build if any stage fails
1. **Restore** with locked central versions (`Directory.Packages.props`).
2. **Build** `-warnaserror` (matches `TreatWarningsAsErrors`); analyzers run.
3. **Format check**: `dotnet format --verify-no-changes` (enforces `.editorconfig`).
4. **Unit tests** (fast, no containers).
5. **Integration tests** with Testcontainers (Postgres/Redis) — runner needs Docker.
6. **Coverage**: collect with coverlet; fail if Domain/Application below the gate (see
   `standards/testing.md`).
7. **Security scans:**
   - Dependency vulnerabilities: `dotnet list package --vulnerable --include-transitive`
     (fail on any), plus a scanner (e.g. Dependabot/Trivy).
   - **SAST** on the C# (e.g. CodeQL) — fail on high severity.
   - Secret scanning on the diff (block committed secrets).
8. **Container build** + image scan (Trivy) for the API and worker images.

## CD
- Build once, promote the same image dev → staging → prod (no rebuild per env).
- **EF migrations**: apply as a separate, gated step using backward-compatible (expand/
  contract) migrations so rolling deploys don't break the running version.
- Rolling/blue-green deploy with health checks (see observability); automatic rollback on
  failed health.
- Secrets injected from the environment's secret store — never baked into images.

## Rules
- Branch protection: PRs must pass CI + review before merge to main.
- The pipeline is the single enforcement point for the standards files; keep it in sync with them.
