#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="/tmp/marees-ambre-layout-snapshot"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode 27.1.app/Contents/Developer}"

DEVELOPER_DIR="$DEVELOPER_DIR" /usr/bin/xcrun swiftc \
  -module-cache-path /tmp/MareesAmbreSwiftModuleCache \
  "$ROOT/MareesAmbre/Domain/SettlementLayout.swift" \
  "$ROOT/MareesAmbre/Domain/L10n.swift" \
  "$ROOT/Tests/LayoutSnapshotChecks.swift" \
  -o "$OUT"
"$OUT"
