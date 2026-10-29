#!/usr/bin/env bash
# usage: bash .bughunt/review-pkg.sh <BASE> <label> [HEAD]     (run from repo root)
# Writes one file for the reviewer: commits, stat and full diff (10 lines of context) of BASE..HEAD.
# Prints only the path and its size, so the diff never enters the session's context.
set -u
BASE=${1:?usage: review-pkg.sh <BASE> <label> [HEAD]}
L=${2:?usage: review-pkg.sh <BASE> <label> [HEAD]}
HEAD_=${3:-HEAD}
D=.bughunt/review; mkdir -p "$D"
L=$(printf '%s' "$L" | tr -c 'A-Za-z0-9._-' '_')
OUT="$D/$L-$(date +%H%M%S).diff"
git rev-parse --verify -q "$BASE^{commit}" >/dev/null || { echo "unknown BASE: $BASE"; exit 1; }
{
  echo "# review package $L   base=$(git rev-parse --short "$BASE") head=$(git rev-parse --short "$HEAD_")"
  echo; echo "## commits"; git log --oneline "$BASE..$HEAD_"
  echo; echo "## stat"; git diff --stat "$BASE" "$HEAD_"
  echo; echo "## diff"; git diff -U10 "$BASE" "$HEAD_"
} > "$OUT"
n=$(git rev-list --count "$BASE..$HEAD_")
[ "$n" -eq 0 ] && echo "WARN: no commits in $BASE..$HEAD_ (uncommitted work is not included — commit first)"
if git diff "$BASE" "$HEAD_" | grep -qE '^\+.*\bBH[0-9]+\b'; then echo "WARN: debug probes (BHn) left in the diff"; fi
echo "$OUT  commits=$n  lines=$(wc -l < "$OUT" | tr -d ' ')"
