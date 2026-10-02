#!/bin/sh

set -eu

cd "$(dirname "$0")/.."

CHECK_DIR=$(mktemp -d /tmp/marees-checks.XXXXXX)

/usr/bin/xcrun swiftc -module-cache-path "$CHECK_DIR/cache" \
  MareesAmbre/Domain/WorldMap.swift \
  MareesAmbre/Domain/L10n.swift \
  MareesAmbre/Domain/BotFaction.swift \
  MareesAmbre/Domain/TileCoordinate.swift \
  Tests/WorldMapChecks.swift \
  -o "$CHECK_DIR/worldmap-checks"

"$CHECK_DIR/worldmap-checks"

rm -rf "$CHECK_DIR"