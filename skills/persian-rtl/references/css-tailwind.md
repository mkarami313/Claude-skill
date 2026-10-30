# Physical → logical: CSS and Tailwind

In RTL, `start` = right, `end` = left. Logical properties make one stylesheet work for both directions.

## CSS mapping
| Physical (avoid) | Logical (use) |
|---|---|
| `margin-left` / `margin-right` | `margin-inline-start` / `margin-inline-end` |
| `margin-left` + `margin-right` | `margin-inline` |
| `padding-left` / `padding-right` | `padding-inline-start` / `padding-inline-end` |
| `left` / `right` (positioned) | `inset-inline-start` / `inset-inline-end` |
| `border-left` / `border-right` | `border-inline-start` / `border-inline-end` |
| `border-top-left-radius` | `border-start-start-radius` |
| `border-top-right-radius` | `border-start-end-radius` |
| `border-bottom-left-radius` | `border-end-start-radius` |
| `border-bottom-right-radius` | `border-end-end-radius` |
| `text-align: left` / `right` | `text-align: start` / `end` |
| `float: left` / `right` | `float: inline-start` / `inline-end` |
| `clear: left` / `right` | `clear: inline-start` / `inline-end` |
| `scroll-margin-left` / `scroll-padding-left` | `scroll-margin-inline-start` / `scroll-padding-inline-start` |

`text-align: right` in an RTL-only design is not wrong visually, but `start` survives an LTR (English) version of the same page — prefer it.

## Tailwind mapping (v3.3+ and v4; a few, like `float-start`, arrived in later 3.x — check your version)
| Physical | Logical |
|---|---|
| `ml-* mr-*` | `ms-* me-*` |
| `pl-* pr-*` | `ps-* pe-*` |
| `left-* right-*` | `start-* end-*` |
| `text-left text-right` | `text-start text-end` |
| `rounded-l-* rounded-r-*` | `rounded-s-* rounded-e-*` |
| `rounded-tl-* rounded-tr-* rounded-bl-* rounded-br-*` | `rounded-ss-* rounded-se-* rounded-es-* rounded-ee-*` |
| `border-l-* border-r-*` | `border-s-* border-e-*` |
| `float-left float-right` | `float-start float-end` |
| `scroll-ml-* scroll-pl-*` | `scroll-ms-* scroll-ps-*` |

- `space-x-*` / `divide-x-*`: how they handle RTL depends on the Tailwind version; prefer `gap-*` on a flex/grid parent, which is direction-safe everywhere.
- Things with no logical class (translate, shadows, gradients): use the `rtl:` / `ltr:` variants, e.g. `translate-x-2 rtl:-translate-x-2`, `bg-gradient-to-r rtl:bg-gradient-to-l`.
- `rtl:`/`ltr:` variants respond to the nearest `dir` attribute — another reason to set `dir` in markup.

## SCSS / frameworks
- Bootstrap 5 has an official RTL build (`bootstrap.rtl.min.css`) and uses `ms-/me-/ps-/pe-` utilities — use the RTL CSS, don't hand-flip.
- Old CSS full of `left/right`: either convert to logical, or generate a mirrored file with RTLCSS (PostCSS plugin) at build time — not both.
- Material UI: `createTheme({ direction: 'rtl' })` plus the RTL Emotion cache (`stylis-plugin-rtl`); the theme setting alone does not flip styles.

## Mixed pages
A Persian page with an English block (code, an English quote): `<div dir="ltr" lang="en">`. Logical properties inside it flip back automatically.
