---
name: persian-rtl
description: Build, review or fix Persian (Farsi) right-to-left web UIs — RTL layout with CSS logical properties and Tailwind, icon mirroring, bidi text, Persian/Arabic digits and characters (ی/ي, ک/ك), ZWNJ, Jalali (Shamsi) dates, Tehran time, number and price formatting, and Persian fonts. Use when creating or converting an RTL page, template, component or store front, fixing RTL bugs, or auditing a front end for Persian users; includes a lint script.
---

# Persian RTL UIs

Claude's usual RTL mistakes: flipping things twice (`flex-row-reverse` on top of `dir="rtl"`), using `left/right` everywhere, mirroring icons that must not mirror, parsing `۱۲۳` as NaN, storing `ي` and `ك` so search fails, and formatting dates with a Gregorian calendar. Fix the **direction model** first; details are in `references/`.

## Direction model — get this right and most of RTL is free
1. Set direction once, in markup: `<html lang="fa" dir="rtl">`. Not `direction: rtl` in CSS (it does not change `:dir()`, form controls or browser bidi in the same way).
2. Flexbox, grid and inline flow **already follow `dir`**. Never add `flex-row-reverse`, `row-reverse` or `order` to "make it RTL" — that flips back to LTR.
3. Write every horizontal value as **logical**: `margin-inline-start`, `padding-inline-end`, `inset-inline-start`, `text-align: start`, `border-inline-start`, `border-start-end-radius`, `float: inline-start`. Tailwind: `ms-* me-* ps-* pe-* start-* end-* text-start text-end rounded-s-* rounded-e-* border-s border-e`.
4. Things logical properties do **not** flip — handle by hand under `[dir="rtl"]` / `:dir(rtl)` / Tailwind `rtl:`: `transform: translateX()`, `box-shadow` x-offset, `background-position`, gradients `to right`, keyframe animations that slide, `scrollLeft` (negative in RTL in modern browsers), canvas/SVG drawing, JS position math (`getBoundingClientRect().left`).
5. Third-party widgets need their own RTL switch: sliders/carousels (Swiper: `dir="rtl"` on the container; Slick: `rtl: true`), date pickers, charts, rich-text editors, maps. Check every one.

## Mirror or not
| Mirror (direction-meaningful) | Never mirror |
|---|---|
| Back/forward arrows, chevrons in breadcrumbs, "next/previous", pagination, carousel arrows, progress/stepper direction, send button, undo/redo, list-bullet/indent icons, text-direction icons | Logos, brand marks, checkmarks, play/pause/media controls, clocks, search magnifier, cart, phone, shapes with no direction, charts' numeric axes, code |
Mirror with `[dir="rtl"] .icon-dir { transform: scaleX(-1); }` (or `rtl:-scale-x-100`), only on icons marked as directional.

## Text, digits and characters — the bugs that break data, not just looks
- **Normalize on input and before search/storage:** `ي` (U+064A) → `ی` (U+06CC), `ك` (U+0643) → `ک` (U+06A9); Persian `۰–۹` (U+06F0–06F9) and Arabic-Indic `٠–٩` (U+0660–0669) → ASCII `0–9` before parsing or saving. Apply the same normalization to the search query and to stored data (or a normalized search column), or search misses half the results.
- **Display** digits in Persian with `Intl.NumberFormat('fa-IR')` / `toLocaleString('fa-IR')`. Never store Persian digits; never send them in JSON numbers.
- **ZWNJ (نیم‌فاصله, U+200C)** is part of the word (`می‌خواهم`, `کتاب‌ها`). Don't strip it in trim/sanitize, don't replace it with a space, keep it in slugs or convert it to `-`, and include it in "allowed characters" validators.
- **Mixed-direction text:** wrap user content in `<bdi>` or set `dir="auto"`; force `dir="ltr"` on phone numbers, e-mail, URLs, IBAN/card numbers, codes, and their `<input>`s (keep `text-align: end`/`right` so they align with the RTL form). Use `unicode-bidi: isolate` for inline LTR runs inside Persian sentences.
- Inputs for numbers: `inputmode="numeric"`, accept both digit sets, normalize on change.

## Dates and time
- Store and compute in UTC (`DateTimeOffset`/ISO with `Z`); convert to Jalali only for display/input.
- Iran time is **Asia/Tehran, UTC+03:30, no DST since 2023**. Always use the IANA zone, keep tzdata current — outdated systems still jump an hour in spring.
- JS display: `new Intl.DateTimeFormat('fa-IR-u-ca-persian', { dateStyle: 'long', timeZone: 'Asia/Tehran' })`. Jalali math and pickers: see `references/jalali.md`. Week starts on **Saturday**; Friday is the weekend.

## Numbers, money, typography
- Prices: `۱۲٬۵۰۰ تومان` — `Intl.NumberFormat('fa-IR')` + the unit as a word after the number. Keep the internal amount an integer in Rial (see the `iran-payments` skill).
- Fonts and line height: see `references/typography.md`. Never `letter-spacing` or `text-transform` on Persian; no fake italic; line-height around 1.7–2.

## References — load only what the task needs
| File | When |
|---|---|
| `references/css-tailwind.md` | Writing or converting CSS/SCSS/Tailwind; physical → logical mapping table; RTL/LTR mixed pages |
| `references/jalali.md` | Date display, pickers, Jalali math in JS and .NET, Tehran time zone |
| `references/typography.md` | Persian fonts (licenses!), loading, digit variants, line height, justification |
| `references/text-data.md` | Normalization code (JS, C#, SQL), search, validation, slugs, sorting |

## Lint script
`python3 <skill-dir>/scripts/rtl_lint.py <path> [--max N]` — scans CSS/SCSS/LESS/HTML/JSX/TSX/Vue/Svelte/Razor/C#/TS files and prints one line per problem: physical CSS properties, physical Tailwind classes, `row-reverse`, Arabic `ي`/`ك` in source strings, `text-align: left/right`. Exit 1 when it finds something. Silence a deliberate line with a `rtl-ok` comment on it. Run it before and after a conversion and report the counts.

## Review / conversion workflow
1. `dir` + `lang` on `<html>`; remove CSS `direction` hacks and any `row-reverse` added for RTL.
2. Run the lint; convert physical → logical (mapping in `references/css-tailwind.md`); fix the non-flipping list (rule 4) by hand.
3. Mark directional icons; check every third-party widget.
4. Input pipeline: digit + character normalization, ZWNJ preserved, LTR fields isolated.
5. Dates: UTC storage, Jalali display, Asia/Tehran.
6. Visual check in a browser at mobile and desktop width, with long Persian words and mixed English (brand names, numbers). Re-run the lint.
