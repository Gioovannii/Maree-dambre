#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="/tmp/marees-ambre-layout-snapshot"
source "$ROOT/Scripts/xcode-environment.sh"

DEVELOPER_DIR="$DEVELOPER_DIR" /usr/bin/xcrun swiftc \
  -module-cache-path /tmp/MareesAmbreSwiftModuleCache \
  "$ROOT/MareesAmbre/Domain/SettlementLayout.swift" \
  "$ROOT/Tests/LayoutSnapshotChecks.swift" \
  -o "$OUT"
"$OUT"
