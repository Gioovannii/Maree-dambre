#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
CHECK_DIR=$(mktemp -d /tmp/marees-session.XXXXXX)
xcrun swiftc -D DEBUG -swift-version 6 -module-cache-path "$CHECK_DIR/cache" MareesAmbre/Domain/*.swift MareesAmbre/Persistence/VillageStorage.swift MareesAmbre/Features/VillageSession.swift Tests/Support/ConstructionActivityController.swift Tests/ShipmentChecks.swift Tests/SessionChecks.swift Tests/TestModeSessionChecks.swift -o "$CHECK_DIR/session-checks"
"$CHECK_DIR/session-checks"
