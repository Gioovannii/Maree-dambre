import Foundation

extension DomainChecks {
    static func checkCoastalDefense() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let world = WorldMap(seed: 42)
        var village = VillageState(seed: 42)
        let initial = village
        precondition(!village.advanceCoastalTide() && village == initial)
        precondition(!village.startCoastalCampaign() && village == initial)
        village.people = .sauniers
        village.buildings[10] = .warCourt
        precondition(!village.startCoastalCampaign(), "An empty village cannot activate the campaign")
        village.army = ArmyState(units: [.tideguard: 2], unlockedUnits: [.tideguard])
        village.resources = Resources(wood: 100, amber: 7, provisions: 21)
        village.lastProductionAt = now
        village.lastBotExpansionAt = now
        precondition(village.startCoastalCampaign())
        let activated = village
        precondition(!village.startCoastalCampaign() && village == activated, "Cannot reset enemy progression")
        precondition(village.coastalCampaign?.tidesUntilAssault == 2)
        let stocks = village.resources
        let troops = village.army
        precondition(village.advanceCoastalTide())
        precondition(village.resources == stocks && village.army == troops && village.coastalCampaign?.report == nil)
        precondition(village.coastalCampaign?.tidesUntilAssault == 1)
        let threatened = village.coastalCampaign
        _ = village.updateInRealTime(now: now.addingTimeInterval(30 * 86_400), on: world)
        precondition(village.coastalCampaign == threatened && village.army == troops,
                     "A month away cannot resolve or strengthen a pending assault")
        village.resources = stocks
        let predicted = village.defensePreview!
        precondition(!predicted.won && predicted.enemyPower == 24 && predicted.garrisonPower == 20)
        precondition(predicted.losses == [.tideguard: 1])
        precondition(predicted.stolen == Resources(wood: 8, amber: 0, provisions: 1))
        let fields = village.resourceLevels
        let buildings = village.buildings
        precondition(village.advanceCoastalTide())
        precondition(village.coastalCampaign?.report == predicted, "Projection and actual battle must agree")
        precondition(village.availableArmy == [.tideguard: 1])
        precondition(village.resources == Resources(wood: 92, amber: 7, provisions: 20))
        precondition(village.buildings == buildings && village.resourceLevels == fields)
        precondition(village.coastalCampaign?.tide == 2 && village.coastalCampaign?.enemyPower == 36)
        precondition(village.coastalCampaign?.tidesUntilAssault == 3)
        let settled = village
        precondition(village.advanceCoastalTide())
        precondition(village.resources == settled.resources && village.army == settled.army,
                     "A later preparation tide cannot replay the previous battle")

        var fortified = activated
        fortified.buildings[11] = .watchtower
        precondition(fortified.garrisonDefense == 40 && fortified.defensePreview?.won == true)
        precondition(fortified.advanceCoastalTide() && fortified.advanceCoastalTide())
        precondition(fortified.availableArmy[.tideguard] == 2 && fortified.resources == activated.resources)
        precondition(fortified.coastalCampaign?.report?.fortificationPower == 20)

        var equal = activated
        equal.army = ArmyState(units: [.pillager: 8], unlockedUnits: [.pillager])
        precondition(equal.garrisonDefense == 24 && equal.defensePreview?.won == true,
                     "A tied defensive battle holds the port")

        var divided = activated
        divided.army = ArmyState(units: [.tideguard: 10, .pillager: 4], unlockedUnits: [.tideguard, .pillager])
        precondition(divided.raid(targetID: 0, units: [.tideguard: 10], now: now))
        let away = divided.army?.raid
        precondition(divided.garrisonDefense == 12 && divided.defensePreview?.won == false)
        divided.army?.training = TrainingOrder(unit: .tideguard, count: 10, endsAt: now.addingTimeInterval(300))
        precondition(divided.defensePreview?.garrisonPower == 12, "Training orders are not defenders")
        precondition(divided.advanceCoastalTide() && divided.advanceCoastalTide())
        precondition(divided.availableArmy == [.pillager: 2] && divided.army?.raid == away)
        precondition(divided.army?.training?.count == 10, "A defensive battle leaves queued and deployed units intact")
        divided.updateArmy(now: now.addingTimeInterval(300))
        precondition(divided.availableArmy[.tideguard] == 18 && divided.availableArmy[.pillager] == 2)
        precondition(divided.army?.raid == nil && divided.army?.training == nil && divided.army?.isValid == true)

        for infirmary in [false, true] {
            for mage in [false, true] {
                var protected = activated
                protected.army = ArmyState(units: [.amberSentry: 20, .tideMage: mage ? 1 : 0])
                if infirmary { protected.buildings[13] = .infirmary }
                let expected = infirmary ? (mage ? 1 : 2) : (mage ? 3 : 4)
                precondition(protected.defensePreview?.losses[.amberSentry] == expected)
            }
        }
        var recovering = activated
        recovering.army = ArmyState(units: [.tideguard: 1], unlockedUnits: [.tideguard])
        recovering.resources = Resources(wood: 20, amber: 20, provisions: 20)
        precondition(recovering.advanceCoastalTide() && recovering.advanceCoastalTide())
        precondition(recovering.availableArmy.isEmpty && recovering.resources == Resources(wood: 20, amber: 20, provisions: 20))
        precondition(recovering.canTrain(.tideguard, count: 2), "A defeat leaves the means to rebuild without paying")
        var improving = activated
        let enemyPower = improving.coastalCampaign?.enemyPower
        improving.weaponsLevel = 3
        improving.army?.units[.tideguard] = 100
        precondition(improving.garrisonDefense == 1_300 && improving.coastalCampaign?.enemyPower == enemyPower)

        var progression = fortified
        for _ in 0..<70 { precondition(progression.advanceCoastalTide()) }
        precondition(progression.coastalCampaign?.enemyPower == 252 && progression.coastalCampaign?.isValid == true,
                     "Enemy growth is bounded and independent of real time or army size")
        let suite = "CoastalDefenseChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        try storage.save(settled)
        let restored = try storage.load(seed: 42, world: world, now: now)!
        precondition(restored == settled && restored.coastalCampaign?.report == predicted)
        // A prior version is adopted without enabling attacks for existing players.
        var legacy = initial
        legacy.version = 11
        try storage.save(legacy)
        let migrated = try storage.load(seed: 42, world: world, now: now)!
        precondition(migrated.version == VillageState.currentVersion && migrated.coastalCampaign == nil)

        for corruptCampaign in [CoastalCampaign(tide: -1), CoastalCampaign(tide: Int.max),
                                CoastalCampaign(assaultsResolved: Int.max), CoastalCampaign(tide: 2),
                                CoastalCampaign(tide: 2, assaultsResolved: 1)] {
            var corrupt = activated
            corrupt.coastalCampaign = corruptCampaign
            try storage.save(corrupt)
            do {
                _ = try storage.load(seed: 42, world: world, now: now)
                preconditionFailure("Corrupt campaign should be rejected")
            } catch CocoaError.coderReadCorrupt {}
        }
        var invalidReport = settled
        invalidReport.coastalCampaign?.report?.losses = [.tideguard: Int.max]
        try storage.save(invalidReport)
        do {
            _ = try storage.load(seed: 42, world: world, now: now)
            preconditionFailure("Unbounded battle report should be rejected before summing losses")
        } catch CocoaError.coderReadCorrupt {}
        print("PASS: explicit coastal tides, no offline assaults, garrison-only defense, fortifications, protected stocks and rebuilding")
        print("PASS: mage/infirmary defense, returning troops, bounded enemy progression, battle persistence and corrupt campaign rejection")
    }
}
