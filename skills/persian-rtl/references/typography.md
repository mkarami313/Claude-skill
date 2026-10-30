# Persian typography

## Fonts — check the license before you ship
| Font | License | Notes |
|---|---|---|
| Vazirmatn | SIL OFL (free, commercial OK) | The safe default; variable font; on Google Fonts |
| Estedad, Sahel, Shabnam, Samim, Tanha (Rastikerdar family) | SIL OFL | Free alternatives with different personalities |
| IRANSans, IRANYekan, Yekan Bakh, Dana, Peyda and other commercial families | **Commercial** | Each site/product needs a purchased license. A template sold to others (e.g. on a template marketplace) must not bundle them unless the license allows redistribution — ship an OFL font and document how to switch. |

Before bundling any font, read its license file. Never copy a commercial font from another site.

## Loading
- Self-host WOFF2, `font-display: swap`, preload only the regular weight used above the fold.
- Load 2–3 weights, not all 9; variable fonts replace the set.
- Set the Persian font first and a Latin fallback after it, or Latin text and digits in mixed content use the Persian font's Latin glyphs, which may look off: `font-family: Vazirmatn, system-ui, sans-serif;`.
- Some families ship a separate variant with Persian digits built in (often suffixed "FD" or similar) or a font feature for digits. Prefer formatting digits with `Intl.NumberFormat('fa-IR')` — that works with any font and keeps copy/paste and screen readers consistent.

## Rules
- Line height ~1.7–2 for body text (Persian has tall ascenders/descenders and dots).
- **No `letter-spacing`** — it breaks the joining of letters.
- **No `text-transform`**, no small caps; no italic (browsers fake-slant Persian badly) — use weight or color for emphasis.
- `text-align: justify` creates uneven gaps (browsers don't insert kashida reliably); prefer `start` for body text.
- Body size: Persian looks smaller than Latin at the same px; 15–16 px minimum for body text.
- Ellipsis and clamping work (`text-overflow: ellipsis`, `line-clamp`); test with long words with ZWNJ.
- Punctuation: Persian comma `،`, question mark `؟`, semicolon `؛`; quotes `«…»`. Don't let code "fix" them to Latin.
