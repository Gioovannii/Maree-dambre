#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
CHECK_DIR=$(mktemp -d /tmp/marees-checks.XXXXXX)
xcrun swiftc -module-cache-path "$CHECK_DIR/cache" MareesAmbre/Domain/*.swift MareesAmbre/Persistence/VillageStorage.swift Tests/StorageForecastChecks.swift Tests/RaidRestChecks.swift Tests/HeroEquipmentChecks.swift Tests/HeroMissionChecks.swift Tests/HeroExperienceChecks.swift Tests/HeroChecks.swift Tests/ScheduledBotAttackChecks.swift Tests/ProtectionChecks.swift Tests/MailboxChecks.swift Tests/ShipmentChecks.swift Tests/ExpansionChecks.swift Tests/DomainChecks.swift Tests/CityBuildingsChecks.swift Tests/StorageValidationChecks.swift Tests/RaidSelectionChecks.swift Tests/DefenseChecks.swift Tests/CommerceChecks.swift Tests/ProgressionChecks.swift -o "$CHECK_DIR/domain-checks"
"$CHECK_DIR/domain-checks"
