#!/usr/bin/env bash
# Find the test that pollutes another one (victim passes alone, fails with the others) by bisection.
# usage (run from repo root, backend already built):
#   bash .bughunt/polluter.sh dotnet <Tests.csproj> <TestName>      candidates = test classes of that project
#   bash .bughunt/polluter.sh web <web-dir> <test-file>              candidates = other test files (vitest or jest)
# Prints one line per run, then "exit=<0|1|2> RESULT: ..." (0 = answer found, 1 = usage/setup error, 2 = inconclusive).
# Logs: .bughunt/polluter/      Works with bash 3.2+ (macOS default bash, Git Bash, Linux).
set -u
M=${1:?usage: polluter.sh dotnet <Tests.csproj> <TestName> | web <web-dir> <test-file>}
P=${2:?missing project/web-dir}; V=${3:?missing victim test}
B=$(pwd)/.bughunt; O="$B/polluter"; rm -rf "$O"; mkdir -p "$O"
RUNS=0
ALL=()
done_() { echo "exit=$1 RESULT: $2"; [ -n "${3:-}" ] && echo "$3"; exit "$1"; }

# --- candidates and runner per mode -------------------------------------------------
if [ "$M" = dotnet ]; then
  [ -f "$P" ] || done_ 1 "no such project: $P"
  if grep -qs 'Microsoft.Testing.Platform' global.json && [ "${BH_MTP_FILTER:-}" != vstest ]; then
    done_ 1 "MTP with xUnit v3 filters cannot OR a method with classes." \
      "Set BH_MTP_FILTER=vstest if the framework is MSTest/NUnit; otherwise bisect by hand with [Collection] or by commenting out classes."
  fi
  VB=${V%%(*}                                            # strip theory arguments: Name(x: 1) -> Name
  VM=${VB##*.}                                           # victim method name
  PD=$(dirname "$P")
  FILES=()
  while IFS= read -r x; do FILES+=("$x"); done < <(
    grep -rlE --include='*.cs' '\[(Fact|Theory|Test|TestCase|TestMethod|DataTestMethod)\b' "$PD" | grep -vE '/(bin|obj)/')
  [ "${#FILES[@]}" -eq 0 ] && done_ 1 "no test files found under $PD"
  # class declarations only (not "class" inside comments/strings); abstract bases never run on their own
  DECL='^[[:space:]]*((public|internal|private|protected|sealed|static|partial|file)[[:space:]]+)*class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*'
  classes() { grep -hoE "$DECL" "$@" | grep -vE '\babstract\b' | awk '{print $NF}'; }
  VF=$(grep -lE "\b$VM[[:space:]]*(<[^>]*>)?[[:space:]]*\(" "${FILES[@]}" 2>/dev/null | head -1)
  VC=""; [ -n "$VF" ] && VC=$(classes "$VF" | tr '\n' ' ')
  while IFS= read -r c; do
    case " $VC " in *" $c "*) ;; *) ALL+=("$c");; esac
  done < <(classes "${FILES[@]}" | sort -u)
  [ -n "$VC" ] && echo "victim class(es): $VC(excluded; if the polluter is in the same class, run that class alone)"
  if grep -qs 'Microsoft.Testing.Platform' global.json; then base=(test --project "$P" --no-build --report-trx)
  else base=(test "$P" --no-build -nologo -v q -tl:off --logger trx); fi
  # exact method match on the first field of a bh.py line: "Ns.Class.Method(args) | msg | file:line"
  is_victim() { awk -F' [|] ' -v m="$VM" '{n=$1; sub(/\(.*/, "", n); sub(/.*\./, "", n); if (n == m) f=1} END {exit !f}' "$1"; }
  run() {  # $@ = candidate classes; returns 0 if the victim FAILED, 1 if it passed, 2 if it did not run
    local f="FullyQualifiedName~$VB" c d="$O/r$RUNS"; RUNS=$((RUNS+1)); mkdir -p "$d"
    for c in "$@"; do f="$f|FullyQualifiedName~.$c."; done
    dotnet "${base[@]}" --results-directory "$d" --filter "$f" > "$d.log" 2>&1
    python3 "$B/bh.py" tests "$d" > "$d.failed"
    if ! grep -rqsE "testName=\"([^\"]*\.)?$VM[\"(]" "$d"; then echo "WARN: victim did not run (check the name) — $d.log"; return 2; fi
    is_victim "$d.failed"
  }
elif [ "$M" = web ]; then
  W=${P%/}; [ -f "$W/package.json" ] || done_ 1 "no package.json in $W"
  X="npx --no"
  for d in "$W" .; do
    if [ -f "$d/pnpm-lock.yaml" ]; then X="pnpm exec"; break; fi
    if [ -f "$d/yarn.lock" ]; then X="yarn"; break; fi
    if [ -f "$d/package-lock.json" ]; then break; fi
  done
  VR=${V#"$W"/}                                          # victim path relative to web-dir
  [ -f "$W/$VR" ] || done_ 1 "no such test file: $W/$VR"
  while IFS= read -r x; do ALL+=("$x"); done < <(cd "$W" && find . -type f \( -name '*.test.*' -o -name '*.spec.*' \) \
                     -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/e2e/*' \
                     | sed 's#^\./##' | grep -vxF "$VR" | sort)
  if grep -qs '"vitest"' "$W/package.json" package.json; then runner=vitest; else runner=jest; fi
  # the first field of a bh.py line is "<test file> > <test name>"; match the victim file in it
  is_victim() { awk -F' [|] ' -v v="$VR" 'index($1, v " > ") || index($1, "/" v " > ") {f=1} END {exit !f}' "$1"; }
  run() {
    local d="$O/r$RUNS"; RUNS=$((RUNS+1)); mkdir -p "$d"
    if [ "$runner" = vitest ]; then
      ( cd "$W" && $X vitest run --no-file-parallelism --reporter=junit --outputFile="$d/junit.xml" "$VR" "$@" ) > "$d.log" 2>&1
    else
      ( cd "$W" && $X jest --ci --runInBand --json --outputFile="$d/jest.json" --runTestsByPath "$VR" "$@" ) > "$d.log" 2>&1
    fi
    if [ -z "$(ls -A "$d")" ]; then echo "WARN: no report written — $d.log"; return 2; fi
    python3 "$B/bh.py" tests "$d" > "$d.failed"
    is_victim "$d.failed"
  }
else
  done_ 1 "mode must be dotnet or web"
fi

echo "candidates=${#ALL[@]}"
[ "${#ALL[@]}" -eq 0 ] && done_ 1 "no candidate tests found"

# --- bisection ------------------------------------------------------------------------
run; r=$?
[ $r -eq 2 ] && done_ 2 "victim did not run alone — fix the name/path first."
[ $r -eq 0 ] && done_ 0 "the victim fails ALONE — not pollution; debug it as a normal bug."
echo "alone: pass"
run "${ALL[@]}"; r=$?
[ $r -eq 2 ] && done_ 2 "victim did not run with the candidates — see the log above."
[ $r -ne 0 ] && done_ 2 "not reproduced with all ${#ALL[@]} candidates (ordering/parallel timing?)." \
  "Try again, or check timing per references/root-cause.md."
echo "all: FAIL — bisecting"
S=("${ALL[@]}")
while [ "${#S[@]}" -gt 1 ]; do
  h=$(( ${#S[@]} / 2 )); A=("${S[@]:0:h}"); Bh=("${S[@]:h}")
  run "${A[@]}"; r=$?
  [ $r -eq 2 ] && done_ 2 "a run did not execute the victim — stopped (runs=$RUNS)."
  if [ $r -eq 0 ]; then S=("${A[@]}"); echo "  ${#S[@]} left (first half)"; continue; fi
  run "${Bh[@]}"; r=$?
  [ $r -eq 2 ] && done_ 2 "a run did not execute the victim — stopped (runs=$RUNS)."
  if [ $r -eq 0 ]; then S=("${Bh[@]}"); echo "  ${#S[@]} left (second half)"; continue; fi
  done_ 2 "no single half reproduces it — the pollution needs tests from both halves, or depends on order (runs=$RUNS):" \
    "$(printf '  %s\n' "${S[@]}" | head -20)"
done
done_ 0 "polluter = ${S[0]}   (runs=$RUNS)" \
  "Next: read what ${S[0]} leaves behind (static/singleton state, DB rows, env, fake clock, module store) and fix its cleanup."
