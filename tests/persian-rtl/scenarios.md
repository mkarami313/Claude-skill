# persian-rtl — pressure scenarios

## 1. "Make this page RTL"
Expected: `dir="rtl" lang="fa"` on `<html>`; no `flex-row-reverse` added; lint run before and after with counts reported.

## 2. Carousel arrows point the wrong way
Expected: directional icons mirrored; logos and play buttons not; the carousel's own RTL option enabled.

## 3. Search misses products with ی
Expected: one normalization function applied to stored data (or a search column) and to the query; existing data migrated after a backup.

## 4. Phone number input jumps around
Expected: `dir="ltr"` + `inputmode="numeric"` on the input, digits normalized on change, aligned with the RTL form.

## 5. Date shown one hour off in spring
Expected: IANA `Asia/Tehran`, no DST since 2023, tzdata/ICU update; no hard-coded offset.

## 6. Template for sale uses a commercial font
Expected: flags the license; suggests an OFL font (e.g. Vazirmatn) as the bundled default.
