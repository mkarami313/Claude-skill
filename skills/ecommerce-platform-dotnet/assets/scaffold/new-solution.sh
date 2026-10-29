#!/usr/bin/env bash
# Scaffolds the modular-monolith solution skeleton. Run once at repo root.
# Idempotent-ish: it won't recreate projects that already exist.
# Requires .NET 10 SDK. (PowerShell users: the dotnet commands are identical.)
set -euo pipefail

SLN="Shop"

echo "==> Creating solution + shared files"
dotnet new sln -n "$SLN" 2>/dev/null || true
# Copy the shared build files shipped with the skill next to this script's parent (assets/):
cp "$(dirname "$0")/../Directory.Build.props"   ./Directory.Build.props
cp "$(dirname "$0")/../Directory.Packages.props" ./Directory.Packages.props
cp "$(dirname "$0")/../.editorconfig"            ./.editorconfig

mkdir -p src/BuildingBlocks src/Modules src/Api tests

echo "==> BuildingBlocks (shared kernel)"
for layer in Domain Application Infrastructure; do
  proj="src/BuildingBlocks/BuildingBlocks.$layer"
  [ -d "$proj" ] || dotnet new classlib -n "BuildingBlocks.$layer" -o "$proj"
  dotnet sln "$SLN.sln" add "$proj" 2>/dev/null || true
done

echo "==> API host"
[ -d src/Api ] && [ -f src/Api/*.csproj ] 2>/dev/null || dotnet new webapi -n "$SLN.Api" -o src/Api --no-https=false
dotnet sln "$SLN.sln" add src/Api 2>/dev/null || true

echo "==> Done. Next: ./assets/scaffold/new-module.sh Catalog"
echo "   Then wire modules in src/Api (AddXModule/UseXModule) per modules/00-architecture."
