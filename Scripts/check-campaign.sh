#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
CHECK_DIR=$(mktemp -d /tmp/marees-campaign.XXXXXX)
trap 'rm -rf "$CHECK_DIR"' EXIT
xcrun swiftc -module-cache-path "$CHECK_DIR/cache" MareesAmbre/Domain/*.swift MareesAmbre/Persistence/VillageStorage.swift Tests/CampaignJourneyChecks.swift -o "$CHECK_DIR/campaign-checks"
TZ=UTC "$CHECK_DIR/campaign-checks"
