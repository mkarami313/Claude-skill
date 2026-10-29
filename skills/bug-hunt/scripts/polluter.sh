#!/usr/bin/env bash
# Find the test that pollutes another one (victim passes alone, fails with the others) by bisection.
# usage (run from repo root, backend already built):
#   bash .bughunt/polluter.sh dotnet <Tests.csproj> <TestName>      candidates = test classes of that project
#   bash .bughunt/polluter.sh web <web-dir> <test-file>              candidates = other test files (vitest or jest)
# Prints one line per run and the result. Logs: .bughunt/polluter/
set -u
M=${1:?usage: polluter.sh dotnet <Tests.csproj> <TestName> | web <web-dir> <test-file>}
P=${2:?missing project/web-dir}; V=${3:?missing victim test}
B=$(pwd)/.bughunt; O="$B/polluter"; rm -rf "$O"; mkdir -p "$O"
RUNS=0

# --- candidates and runner per mode -------------------------------------------------
if [ "$M" = dotnet ]; then
  [ -f "$P" ] || { echo "no such project: $P"; exit 1; }
  if grep -qs 'Microsoft.Testing.Platform' global.json && [ "${BH_MTP_FILTER:-}" != vstest ]; then
    echo "MTP with xUnit v3 filters cannot OR a method with classes; set BH_MTP_FILTER=vstest if the framework is MSTest/NUnit, otherwise bisect by hand with [Collection] or by commenting out classes."
    exit 2
  fi
  VM=${V%%(*}; VM=${VM##*.}                              # victim method name
  PD=$(dirname "$P")
  files=$(grep -rlE --include='*.cs' '\[(Fact|Theory|Test|TestCase|TestMethod|DataTestMethod)\b' "$PD" | grep -vE '/(bin|obj)/')
  VF=$(grep -lE "\b$VM[[:space:]]*\(" $files 2>/dev/null | head -1)
  VC=""; [ -n "$VF" ] && VC=$(grep -oE 'class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' "$VF" | awk '{print $2}' | tr '\n' ' ')
  mapfile -t ALL < <(grep -ohE 'class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' $files | awk '{print $2}' | sort -u \
                     | while read -r c; do case " $VC " in *" $c "*) ;; *) echo "$c";; esac; done)
  [ -n "$VC" ] && echo "victim class(es): $VC(excluded; if the polluter is in the same class, run that class alone)"
  if grep -qs 'Microsoft.Testing.Platform' global.json; then base=(test --project "$P" --no-build --report-trx)
  else base=(test "$P" --no-build -nologo -v q -tl:off --logger trx); fi
  run() {  # $@ = candidate classes; returns 0 if the victim FAILED
    local f="FullyQualifiedName~$V" c d="$O/r$RUNS"; RUNS=$((RUNS+1)); mkdir -p "$d"
    for c in "$@"; do f="$f|FullyQualifiedName~.$c."; done
    dotnet "${base[@]}" --results-directory "$d" --filter "$f" > "$d.log" 2>&1
    python3 "$B/bh.py" tests "$d" > "$d.failed"
    if ! grep -rqs "$VM" "$d"/*.trx; then echo "WARN: victim did not run (check the name) — $d.log"; return 2; fi
    grep -qF "$VM" "$d.failed"
  }
elif [ "$M" = web ]; then
  W=${P%/}; [ -f "$W/package.json" ] || { echo "no package.json in $W"; exit 1; }
  X="npx --no"
  for d in "$W" .; do
    if [ -f "$d/pnpm-lock.yaml" ]; then X="pnpm exec"; break; fi
    if [ -f "$d/yarn.lock" ]; then X="yarn"; break; fi
    if [ -f "$d/package-lock.json" ]; then break; fi
  done
  VR=${V#"$W"/}                                          # victim path relative to web-dir
  [ -f "$W/$VR" ] || { echo "no such test file: $W/$VR"; exit 1; }
  mapfile -t ALL < <(cd "$W" && find . -type f \( -name '*.test.*' -o -name '*.spec.*' \) \
                     -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/e2e/*' \
                     | sed 's#^\./##' | grep -vxF "$VR" | sort)
  if grep -qs '"vitest"' "$W/package.json" package.json; then runner=vitest; else runner=jest; fi
  run() {
    local d="$O/r$RUNS"; RUNS=$((RUNS+1)); mkdir -p "$d"
    if [ "$runner" = vitest ]; then
      ( cd "$W" && $X vitest run --no-file-parallelism --reporter=junit --outputFile="$d/junit.xml" "$VR" "$@" ) > "$d.log" 2>&1
    else
      ( cd "$W" && $X jest --ci --runInBand --json --outputFile="$d/jest.json" --runTestsByPath "$VR" "$@" ) > "$d.log" 2>&1
    fi
    python3 "$B/bh.py" tests "$d" > "$d.failed"
    if [ -z "$(ls -A "$d")" ]; then echo "WARN: no report written — $d.log"; return 2; fi
    grep -qF "$(basename "$VR")" "$d.failed"
  }
else
  echo "mode must be dotnet or web"; exit 1
fi

echo "candidates=${#ALL[@]}"
[ "${#ALL[@]}" -eq 0 ] && { echo "no candidate tests found"; exit 1; }

# --- bisection ------------------------------------------------------------------------
run; r=$?
[ $r -eq 2 ] && exit 2
[ $r -eq 0 ] && { echo "RESULT: the victim fails ALONE — not pollution; debug it as a normal bug."; exit 0; }
echo "alone: pass"
run "${ALL[@]}"; r=$?
[ $r -eq 2 ] && exit 2
if [ $r -ne 0 ]; then
  echo "RESULT: not reproduced with all ${#ALL[@]} candidates (ordering/parallel timing?). Try again, or check timing per references/root-cause.md."
  exit 0
fi
echo "all: FAIL — bisecting"
S=("${ALL[@]}")
while [ "${#S[@]}" -gt 1 ]; do
  h=$(( ${#S[@]} / 2 )); A=("${S[@]:0:h}"); Bh=("${S[@]:h}")
  if run "${A[@]}"; then S=("${A[@]}"); echo "  ${#S[@]} left (first half)"
  elif run "${Bh[@]}"; then S=("${Bh[@]}"); echo "  ${#S[@]} left (second half)"
  else
    echo "RESULT: no single half reproduces it — the pollution needs tests from both halves, or depends on order:"
    printf '  %s\n' "${S[@]}" | head -20; echo "runs=$RUNS"; exit 0
  fi
done
echo "RESULT: polluter = ${S[0]}   (runs=$RUNS)"
echo "Next: read what ${S[0]} leaves behind (static/singleton state, DB rows, env, fake clock, module store) and fix its cleanup."
