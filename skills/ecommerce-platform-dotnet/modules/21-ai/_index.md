# Module 21 · AI features — index

Competitive extras, not core. Build after the platform works. Each AI feature is behind an
abstraction + feature flag so a tenant can enable/disable it and swap providers.

## Scope
- Semantic / vector search.
- Personalized recommendations.
- Customer chatbot / shopping assistant.
- Content generation (descriptions, SEO, tags).
- Fraud detection & demand forecasting.

## Sub-files
- `semantic-search.md`, `recommendations.md`, `chatbot-assistant.md`,
  `content-generation.md`, `fraud-forecasting.md`.

## Definition of done
- Each enabled AI feature works behind its abstraction, degrades gracefully when the
  provider is unavailable, is tenant-scoped, and never leaks PII to external models without
  consent/configuration.

## ASVS focus
- V8 (data sent to AI providers governed by consent), V9/SSRF (provider calls allow-listed),
  V5 (prompt-input handling).
