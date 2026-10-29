#!/usr/bin/env bash
# Scaffolds one module's 4 projects + contracts, following the locked layering.
# Usage: ./assets/scaffold/new-module.sh <ModuleName>   e.g. Catalog
set -euo pipefail

NAME="${1:?Usage: new-module.sh <ModuleName>}"
SLN="Shop"
BASE="src/Modules/$NAME"

echo "==> Creating module $NAME"
mkdir -p "$BASE"

create() { # <project-suffix> <template>
  local proj="$BASE/$NAME.$1"
  [ -d "$proj" ] || dotnet new "$2" -n "$NAME.$1" -o "$proj"
  dotnet sln "$SLN.sln" add "$proj" 2>/dev/null || true
}

create Domain          classlib
create Application     classlib
create Infrastructure  classlib
create Api             classlib
create Contracts       classlib   # PUBLIC surface other modules may reference

echo "==> Wiring dependency direction (inward only)"
dotnet add "$BASE/$NAME.Application/$NAME.Application.csproj"       reference "$BASE/$NAME.Domain/$NAME.Domain.csproj"
dotnet add "$BASE/$NAME.Infrastructure/$NAME.Infrastructure.csproj" reference "$BASE/$NAME.Application/$NAME.Application.csproj"
dotnet add "$BASE/$NAME.Api/$NAME.Api.csproj"                       reference "$BASE/$NAME.Application/$NAME.Application.csproj"

echo "==> $NAME created. Reminders:"
echo "   - Reference other modules ONLY via their .Contracts project."
echo "   - Add Postgres schema '$(echo "$NAME" | tr '[:upper:]' '[:lower:]')' for this module's tables."
echo "   - Register Add${NAME}Module / Use${NAME}Module in src/Api."
echo "   - Match reference-implementation/ for code style."
