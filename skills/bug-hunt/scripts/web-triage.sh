#!/usr/bin/env bash
# usage: bash .bughunt/web-triage.sh <web-dir>     (run from repo root)
# Runs tsc, ESLint and unit tests; prints counts and one line per problem.
# Files: .bughunt/ts-errors.txt, lint-errors.txt, failed-web.txt (+ .log files with raw output)
# Env: TSCONFIG=<file inside web-dir> to override the tsconfig that is type-checked.
set -u
W=${1:?usage: web-triage.sh <web-dir>}; W=${W%/}
B=$(pwd)/.bughunt; T="$B/tests/web"
rm -rf "$T"; mkdir -p "$T"
[ -f "$W/package.json" ] || { echo "no package.json in $W"; exit 1; }

X="npx --no"
for d in "$W" .; do
  if [ -f "$d/pnpm-lock.yaml" ]; then X="pnpm exec"; break; fi
  if [ -f "$d/yarn.lock" ]; then X="yarn"; break; fi
  if [ -f "$d/package-lock.json" ]; then break; fi
done
has() { grep -qs "\"$1\"" "$W/package.json" package.json; }

# --- TypeScript
TC=${TSCONFIG:-tsconfig.json}
[ -z "${TSCONFIG:-}" ] && [ -f "$W/tsconfig.app.json" ] && TC=tsconfig.app.json   # Vite: root tsconfig has "files": []
( cd "$W" && $X tsc --noEmit --pretty false -p "$TC" ) > "$B/tsc.log" 2>&1; rc_ts=$?
grep -E 'error TS[0-9]+' "$B/tsc.log" | sed -E "/^[^ ]+\(/ s#^#$W/#" | sort -u > "$B/ts-errors.txt"
n_ts=$(wc -l < "$B/ts-errors.txt" | tr -d ' ')
if [ "$rc_ts" -eq 0 ] && grep -qs '"files"[[:space:]]*:[[:space:]]*\[\]' "$W/$TC"; then
  echo "WARN: $TC has \"files\": [] — tsc checked nothing; rerun with TSCONFIG=<the app tsconfig>"
fi

# --- ESLint (v9 removed unix/compact formatters -> JSON + parser)
rc_l=-; n_l=0
if has eslint; then
  ( cd "$W" && $X eslint . -f json --quiet -o "$B/eslint.json" ) > "$B/eslint.log" 2>&1; rc_l=$?
  if python3 "$B/bh.py" eslint "$B/eslint.json" > "$B/lint-errors.txt" 2>/dev/null; then
    n_l=$(wc -l < "$B/lint-errors.txt" | tr -d ' ')
  else : > "$B/lint-errors.txt"; fi
fi

# --- Unit tests
rc_t=-
if has vitest; then
  ( cd "$W" && $X vitest run --reporter=junit --outputFile="$T/junit.xml" ) > "$B/web-test.log" 2>&1; rc_t=$?
elif has jest; then
  ( cd "$W" && $X jest --ci --json --outputFile="$T/jest.json" ) > "$B/web-test.log" 2>&1; rc_t=$?
fi
python3 "$B/bh.py" tests "$T" > "$B/failed-web.txt"
n_t=$(wc -l < "$B/failed-web.txt" | tr -d ' ')

echo "tsc exit=$rc_ts errors=$n_ts ($TC) | eslint exit=$rc_l errors=$n_l | tests exit=$rc_t failed=$n_t | pm=$X"
if [ "$rc_ts" -ne 0 ] && [ "$n_ts" -eq 0 ]; then echo "WARN tsc failed, nothing parsed:"; tail -8 "$B/tsc.log"; fi
if [ "$rc_l" != - ] && [ "$rc_l" -gt 1 ]; then echo "WARN eslint crashed/misconfigured:"; tail -8 "$B/eslint.log"; fi
if [ "$rc_t" != - ] && [ "$rc_t" -ne 0 ] && [ "$n_t" -eq 0 ]; then echo "WARN tests failed, nothing parsed:"; tail -10 "$B/web-test.log"; fi
[ "$n_ts" -gt 0 ] && { echo "-- tsc by code"; grep -oE 'TS[0-9]+' "$B/ts-errors.txt" | sort | uniq -c | sort -rn | head -8; echo "-- tsc first 15"; head -15 "$B/ts-errors.txt"; }
[ "$n_l" -gt 0 ] && { echo "-- eslint by rule"; cut -d'|' -f2 "$B/lint-errors.txt" | sort | uniq -c | sort -rn | head -8; echo "-- eslint first 15"; head -15 "$B/lint-errors.txt"; }
[ "$n_t" -gt 0 ] && { echo "-- failed tests"; head -20 "$B/failed-web.txt"; }
exit 0
