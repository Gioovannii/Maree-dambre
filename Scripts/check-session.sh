#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
CHECK_DIR=$(mktemp -d /tmp/marees-session.XXXXXX)
xcrun swiftc -swift-version 6 -module-cache-path "$CHECK_DIR/cache" MareesAmbre/Domain/*.swift MareesAmbre/Persistence/VillageStorage.swift MareesAmbre/Features/VillageSession.swift Tests/Support/ConstructionActivityController.swift Tests/SessionChecks.swift -o "$CHECK_DIR/session-checks"
"$CHECK_DIR/session-checks"
