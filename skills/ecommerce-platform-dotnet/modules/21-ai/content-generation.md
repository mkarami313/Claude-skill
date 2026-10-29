# 21 · Content generation

Assists staff in creating catalog/marketing content — always human-reviewed.

## Use cases
- Draft product descriptions from attributes/title.
- Generate SEO meta title/description (11) and suggested tags/categories.
- Image alt-text and basic image tagging.
- Draft marketing copy for campaigns (10) and blog posts (11).
- Translate content across locales (14).

## Approach
- `IContentGenerator` abstraction over an LLM provider; prompts include the product's
  structured data; outputs are **suggestions** placed in draft, never auto-published.

## Rules
- Human-in-the-loop: staff review and approve before publishing.
- Don't fabricate specs/claims; ground on provided product data.
- Tenant-scoped; permissioned; provider calls allow-listed; no secrets in prompts.

## API surface
- Generate description/SEO/tags/translation (returns drafts); accept into the entity.
