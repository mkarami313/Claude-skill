# Jalali (Shamsi) dates and Tehran time

## Rules
- Store UTC (`DateTimeOffset`, ISO 8601 with `Z`/offset). Jalali exists only in the UI and in user input.
- Date-only values (birthday, delivery day) → store as a Gregorian `date` (`DateOnly`), convert at the edges. Don't store Jalali strings like `1403/05/12` in the DB — they don't sort or compute safely across years and libraries.
- Time zone: IANA `Asia/Tehran` (UTC+03:30). Iran has had **no DST since 2023**; systems with old tzdata still shift an hour in spring → update tzdata / ICU, and never hard-code an offset table.
- Week starts Saturday (`شنبه`), Friday (`جمعه`) is the weekend. Calendars and "this week" reports must use that.
- Month lengths: months 1–6 have 31 days, 7–11 have 30, Esfand has 29 (30 in leap years). Never compute Jalali months with Gregorian math.

## JavaScript / TypeScript
Display only — built-in, no library:
```ts
const fmt = new Intl.DateTimeFormat('fa-IR-u-ca-persian', {
  year: 'numeric', month: 'long', day: 'numeric', timeZone: 'Asia/Tehran',
});
fmt.format(new Date('2026-10-29T06:44:00Z'));   // e.g. "۷ آبان ۱۴۰۵"
```
- `month: '2-digit'` gives `۱۴۰۵/۰۸/۰۷`-style output; use `numberingSystem: 'latn'` (or the `-nu-latn` extension: `'fa-IR-u-ca-persian-nu-latn'`) for ASCII digits.
- `formatToParts` to get year/month/day separately.

Math, parsing and pickers need a library — use one, never hand-written conversion:
- `date-fns-jalali` (date-fns API with Jalali), or Day.js + `jalaliday`, or `jalaali-js` for raw conversion.
- Pickers: pick one with Jalali + RTL support and test month boundaries (31 Shahrivar → 1 Mehr, 29/30 Esfand).
Confirm the current package name and version on npm before installing.

## C# / .NET
```csharp
var pc = new System.Globalization.PersianCalendar();
var tehran = TimeZoneInfo.FindSystemTimeZoneById("Asia/Tehran");   // IANA id works on .NET 6+ on all OSes
var local = TimeZoneInfo.ConvertTime(utcNow, tehran);
string jalali = $"{pc.GetYear(local.DateTime):0000}/{pc.GetMonth(local.DateTime):00}/{pc.GetDayOfMonth(local.DateTime):00}";

// Jalali → Gregorian
DateTime g = pc.ToDateTime(1405, 8, 7, 0, 0, 0, 0);
```
- Use `PersianCalendar` explicitly; don't rely on `CultureInfo("fa-IR")` formatting to pick the calendar — it differs between Windows NLS, ICU and versions.
- Docker images based on Alpine need ICU and tzdata packages (`icu-libs`, `tzdata`) or set `InvariantGlobalization=false` knowingly; with invariant mode, culture-based formatting silently becomes invariant.
- Never format dates to Jalali inside the domain or the DB layer; do it in the API response mapper or the UI.

## SQL
Keep Gregorian in the DB. For reports grouped by Jalali month, compute the Jalali month's Gregorian start/end bounds in code and query by range (`>= start AND < next_start`) — never by a Jalali string column.
