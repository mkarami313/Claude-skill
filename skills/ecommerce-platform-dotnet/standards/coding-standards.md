# Coding standards (read once per session)

Apply across every module. The goal is consistent, analyzable, testable C#.

## Build-wide settings (via `assets/Directory.Build.props`, `assets/Directory.Packages.props`, `assets/.editorconfig`)
- `<Nullable>enable</Nullable>`, `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`.
- `<LangVersion>latest</LangVersion>`, `<ImplicitUsings>enable</ImplicitUsings>`.
- `<AnalysisLevel>latest-Recommended</AnalysisLevel>`; .NET analyzers on. StyleCop is
  **optional** (listed in `Directory.Packages.props`, opt-in per project) — not required.
- Central Package Management via `Directory.Packages.props` (versions pinned once); projects
  reference packages without a `Version`.
- XML-doc generation is off by default (see the note in `Directory.Build.props`) so
  undocumented public members don't fail the build under warnings-as-errors.
- **Staging strictness is fine:** keep warnings-as-errors on, but a team may start a brand-new
  project with a scoped `<NoWarn>` and tighten it as the skeleton stabilizes — the CI build
  stays strict.

## Naming & style
- PascalCase for types/methods/properties; camelCase for locals/parameters;
  `_camelCase` for private fields; `I`-prefix for interfaces.
- One public type per file; file name = type name.
- English identifiers and comments. User-facing text is localized, never hard-coded.

## Language use
- `async`/`await` end to end for all I/O; suffix async methods with `Async`;
  pass `CancellationToken` through to I/O calls.
- Prefer immutability: `record` for DTOs/value objects, `init`/`readonly` where possible.
- No `null` surprises: honor nullable annotations; guard public inputs.
- Throw specific exceptions; map them to problem-details responses centrally.

## Structure per module (Clean Architecture)
- `Domain` (entities, value objects, rules) → no external dependencies.
- `Application` (use cases, DTOs, interfaces, validators) → depends on Domain only.
- `Infrastructure` (EF, external services) → implements Application interfaces.
- `Api` (controllers) → thin; delegates to Application.
- Use a mediator pattern (e.g., MediatR) for commands/queries; keep controllers thin.

## Data & API
- Expose DTOs, never entities. Map explicitly.
- Validate with FluentValidation at the Application boundary.
- Return Problem Details (RFC 7807) for errors; use correct HTTP status codes.
- Version the API in the URL; never break a published version.

## Quality gates
- Every use case has at least one test (see `testing.md`).
- No warnings (they are errors). Analyzers must pass.
- No TODOs left for security-relevant logic.
