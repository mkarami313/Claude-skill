#!/usr/bin/env bash
# usage: bash .bughunt/test-dotnet.sh <Solution.sln|Tests.csproj> [TestName]   (run from repo root, after a build)
# Prints "exit= trx= failed=" first, then one line per failed test. Logs: .bughunt/test.log
# Detects Microsoft.Testing.Platform mode (.NET 10, global.json "test": {"runner": ...}).
#   VSTest filter:  --filter "FullyQualifiedName~<name>"
#   MTP filter:     xUnit v3 --filter-method "*<name>*"; set BH_MTP_FILTER=vstest for MSTest/NUnit on MTP.
set -u
T=${1:?usage: test-dotnet.sh <sln|csproj> [TestName]}
F=${2:-}; F=${F%%(*}            # strip theory arguments: Name(x: 1) -> Name
B=.bughunt; D="$B/tests/dotnet"
rm -rf "$D"; mkdir -p "$D"

if grep -qs 'Microsoft.Testing.Platform' global.json; then
  case "$T" in *.sln|*.slnx) tgt=(--solution "$T");; *) tgt=(--project "$T");; esac
  args=(test "${tgt[@]}" --no-build --results-directory "$D" --report-trx)
  if [ -n "$F" ]; then
    if [ "${BH_MTP_FILTER:-}" = vstest ]; then args+=(--filter "FullyQualifiedName~$F")
    else args+=(--filter-method "*$F*"); fi
  fi
  mode=mtp
else
  args=(test "$T" --no-build -nologo -v q -tl:off --logger trx --results-directory "$D")
  [ -n "$F" ] && args+=(--filter "FullyQualifiedName~$F")
  mode=vstest
fi

dotnet "${args[@]}" > "$B/test.log" 2>&1
rc=$?
n=$(find "$D" -name '*.trx' | wc -l | tr -d ' ')
python3 "$B/bh.py" tests "$D" > "$B/failed-tests.txt"
f=$(wc -l < "$B/failed-tests.txt" | tr -d ' ')
echo "exit=$rc trx=$n failed=$f mode=$mode"
[ "$n" -eq 0 ] && echo "WARN: no TRX produced (build missing? MTP without the TRX extension? xUnit v3 can use --report-xunit-trx)"
if [ "$mode" = mtp ] && [ "$rc" -eq 8 ]; then echo "WARN: zero tests ran — check the filter"; fi
grep -qiE 'No test (matches|is available)' "$B/test.log" && echo "WARN: no test matched — check the name/filter"
if [ "$rc" -ne 0 ] && [ "$f" -eq 0 ]; then
  echo "WARN: non-zero exit but no failed test parsed (crash/abort/build?). Relevant log lines:"
  grep -iE 'error|crash|abort|exited|exception' "$B/test.log" | tail -10
fi
# Failures caused by the machine, not the code: DB/Docker/network/secrets missing -> fix the environment first.
ENV_RE='connection refused|actively refused|could not connect|network-related|No such host|Name or service not known|Docker (is not running|daemon)|DockerUnavailable|Testcontainers|SocketException|timeout expired.*(connect|pool)|password authentication failed|Login failed for user|environment variable .* (not set|missing)|ConnectionString'
e=$(grep -ciE "$ENV_RE" "$B/failed-tests.txt")
[ "$e" -gt 0 ] && echo "WARN: $e failure(s) look environmental (DB/Docker/network/config) — log ONE row with Area env, status env; do not fix code for them"
head -40 "$B/failed-tests.txt"
exit "$rc"
