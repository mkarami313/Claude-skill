# Persian text as data — normalization, search, validation

## Normalize (same function everywhere: input, search query, import, stored search column)
| From | To | Code points |
|---|---|---|
| Arabic Yeh `ي`, Alef Maksura `ى` | Persian Yeh `ی` | U+064A, U+0649 → U+06CC |
| Arabic Kaf `ك` | Persian Keheh `ک` | U+0643 → U+06A9 |
| Persian digits `۰–۹` | `0–9` | U+06F0–U+06F9 → U+0030–U+0039 |
| Arabic-Indic digits `٠–٩` | `0–9` | U+0660–U+0669 → U+0030–U+0039 |
| Arabic diacritics (harakat) | removed — **search keys only**, never in displayed text | U+064B–U+065F, U+0670 |
| Tatweel/kashida `ـ` | removed — search keys only | U+0640 |
Keep ZWNJ (U+200C) in stored text. For search keys, either keep it in both sides or replace it with a space in both sides — consistently.

### TypeScript
```ts
export function normalizeFa(s: string): string {
  return s
    .replace(/[يى]/g, 'ی')
    .replace(/ك/g, 'ک')
    .replace(/[۰-۹]/g, d => String(d.charCodeAt(0) - 0x06F0))
    .replace(/[٠-٩]/g, d => String(d.charCodeAt(0) - 0x0660));
}
export const searchKeyFa = (s: string) =>
  normalizeFa(s).replace(/[ً-ٰٟـ]/g, '').replace(/‌/g, ' ').replace(/\s+/g, ' ').trim();
export const toFaDigits = (n: number | string) =>
  typeof n === 'number' ? n.toLocaleString('fa-IR') : n.replace(/\d/g, d => '۰۱۲۳۴۵۶۷۸۹'[+d]);
```

### C#
```csharp
public static string NormalizeFa(string s)
{
    var sb = new StringBuilder(s.Length);
    foreach (var c in s)
        sb.Append(c switch
        {
            'ي' or 'ى' => 'ی',
            'ك' => 'ک',
            >= '۰' and <= '۹' => (char)('0' + (c - '۰')),
            >= '٠' and <= '٩' => (char)('0' + (c - '٠')),
            _ => c
        });
    return sb.ToString();
}
```
Apply it in model binding / a request-level normalizer for text fields, in import pipelines, and when building the search column. `int.Parse("۱۲۳")` works under some cultures and fails under others — always normalize first and parse with `CultureInfo.InvariantCulture`.

### Existing data (SQL Server example)
```sql
UPDATE Products SET Name = REPLACE(REPLACE(Name, NCHAR(1610), NCHAR(1740)), NCHAR(1603), NCHAR(1705));
```
Back up first, run per table/column, and rebuild full-text indexes afterwards. On PostgreSQL use `translate(name, 'يك', 'یک')`.

## Search
- Search on a normalized key column (or a computed/persisted column), and normalize the query with the same function.
- SQL Server full-text: Persian word breaking is limited — consider a search engine (Elasticsearch/OpenSearch with a Persian analyzer, Meilisearch) for real product search.
- `LIKE N'%…%'` needs `N` prefixes in SQL Server, or Persian text becomes `?`.

## Validation
- "Persian letters only": `^[؀-ۿ‌\s]+$` (includes ZWNJ and spaces). Don't use `\w` — it means ASCII in many engines.
- Mobile numbers: normalize digits, then `^09\d{9}$` (accept `+989…`/`00989…` and convert).
- National code (کد ملی): 10 digits with a checksum — validate the checksum, not just the length.
- Postal code: 10 digits.

## Slugs and URLs
Persian slugs are valid (`/محصول/کفش-ورزشی`); percent-encode in links, keep human-readable in the sitemap. Replace spaces and ZWNJ with `-`, normalize characters first, and keep slugs unique after normalization.

## Sorting
Use culture-aware comparison (`StringComparer.Create(new CultureInfo("fa-IR"), false)`, `Intl.Collator('fa')`) and an appropriate DB collation (e.g. `Persian_100_CI_AI` in SQL Server). Default binary/Latin ordering misplaces `پ چ ژ گ`.
