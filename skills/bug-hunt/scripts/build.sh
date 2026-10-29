#!/usr/bin/env bash
# usage: bash .bughunt/build.sh <Solution.sln|Project.csproj>     (run from repo root)
# Writes .bughunt/build.log and .bughunt/build-errors.txt, prints a short summary.
set -u
T=${1:?usage: build.sh <sln|csproj>}
B=.bughunt
dotnet build "$T" -nologo -v q -tl:off -clp:"ErrorsOnly;NoSummary" > "$B/build.log" 2>&1
rc=$?
# Every error line: C# (CS), MSBuild (MSB), NuGet (NU), Razor (RZ), analyzers…; any file type, any path.
grep -E ':[[:space:]]*(fatal )?error [A-Za-z]+[0-9]+' "$B/build.log" \
  | sed -E 's#\\#/#g; s/^[[:space:]]+//; s/ \[[^]]*\]$//' | sort -u > "$B/build-errors.txt"
n=$(wc -l < "$B/build-errors.txt" | tr -d ' ')
echo "exit=$rc errors=$n"
if [ "$rc" -ne 0 ] && [ "$n" -eq 0 ]; then
  echo "WARN: build failed but no error line was parsed. Last log lines:"
  tail -20 "$B/build.log"
  exit "$rc"
fi
[ "$n" -eq 0 ] && exit "$rc"
echo "-- by code"
grep -oE 'error [A-Za-z]+[0-9]+' "$B/build-errors.txt" | sort | uniq -c | sort -rn | head -15
RE=$(cat "$B/module-re" 2>/dev/null || echo 'src/[^/]+')
echo "-- by module ($RE)"
{ grep -oE "$RE" "$B/build-errors.txt" || true; } | sort | uniq -c | sort -rn | head -15
echo "-- first 40"
head -40 "$B/build-errors.txt"
exit "$rc"
