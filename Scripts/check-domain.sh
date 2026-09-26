#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
CHECK_DIR=$(mktemp -d /tmp/marees-checks.XXXXXX)
xcrun swiftc -module-cache-path "$CHECK_DIR/cache" MareesAmbre/Domain/*.swift Tests/DomainChecks.swift -o "$CHECK_DIR/domain-checks"
"$CHECK_DIR/domain-checks"
