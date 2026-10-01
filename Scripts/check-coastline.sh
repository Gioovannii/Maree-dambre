#!/bin/sh

set -eu

cd "$(dirname "$0")/.."

CHECK_DIR=$(mktemp -d /tmp/marees-checks.XXXXXX)

/usr/bin/xcrun swiftc -module-cache-path "$CHECK_DIR/cache" MareesAmbre/Features/CoastlinePath.swift Tests/CoastlineChecks.swift -o "$CHECK_DIR/coastline-checks"

"$CHECK_DIR/coastline-checks"

rm -rf "$CHECK_DIR"