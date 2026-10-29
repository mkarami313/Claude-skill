# 12 · Query handling (Persian-aware)

## Features
- Instant/as-you-type suggestions (autocomplete) and full search.
- Typo tolerance (fuzzy), synonyms, and stop-word handling.
- Prefix and partial matching; relevance ranking by text match + popularity + availability.

## Persian/Farsi specifics (critical for this market)
- Normalize characters: Arabic ↔ Persian (ي/ی, ك/ک), remove/normalize ZWNJ, unify digits
  (Persian/Arabic/Latin), strip diacritics.
- Handle "finglish" (Latin-typed Persian) via transliteration synonyms where feasible.
- Use a Persian analyzer/normalizer in the engine; mirror the same normalization on
  indexing and querying so they match.

## Rules
- Sanitize/escape query input before sending to the engine (no injection).
- Return an "empty result" fallback with suggestions (see facets-sorting) rather than nothing.

## API surface
- Autocomplete; search (query + filters + sort + paging); "did you mean" suggestions.
