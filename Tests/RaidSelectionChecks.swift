import Foundation

extension DomainChecks {
    static func checkRaidSelection() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let world = WorldMap(seed: 42)
        let suite = "RaidSelectionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var base = VillageState(seed: 42)
        base.people = .sauniers
        base.resources = Resources(wood: 0, amber: 0, provisions: 0)
        base.army = ArmyState(units: [.tideguard: 20, .tideMage: 2, .pillager: 4],
            unlockedUnits: [.tideguard, .tideMage, .pillager])

        let invalidSelections: [[ArmyUnit: Int]] = [[:], [.tideguard: 0], [.tideguard: -1],
            [.tideguard: 21], [.tideguard: Int.max], [.tideguard: Int.min],
            [.marshArcher: 1], [.tideguard: 2, .tideMage: -1]]
        for selection in invalidSelections {
            var invalid = base
            precondition(!invalid.canRaid(invalid.bots[0], units: selection, now: now))
            precondition(!invalid.raid(targetID: 0, units: selection, now: now))
            precondition(invalid == base, "Invalid selections cannot consume troops or start a cooldown")
        }
        var unknown = base
        precondition(!unknown.raid(targetID: 99, units: [.tideguard: 2], now: now) && unknown == base)

        var partial = base
        precondition(partial.armyPower(for: [.tideguard: 8]) == 64)
        precondition(partial.raid(targetID: 0, units: [.tideguard: 8, .tideMage: 0], now: now))
        precondition(partial.army?.raid?.units == [.tideguard: 8])
        precondition(partial.availableArmy == [.tideguard: 12, .tideMage: 2, .pillager: 4])
        precondition(partial.army?.raid?.victoryLossRate == 0.2, "A mage at home cannot protect the expedition")
        precondition(partial.army?.isValid == true)
        let underway = partial
        precondition(!partial.raid(targetID: 1, units: [.tideguard: 2], now: now) && partial == underway)
        try storage.save(partial)
        partial = try storage.load(seed: 42, world: world, now: now)!
        precondition(partial == underway, "Selection and garrison must survive relaunch")
        partial.updateArmy(now: now.addingTimeInterval(119))
        precondition(partial.army?.raid != nil && partial.availableArmy == underway.availableArmy)
        partial.updateArmy(now: now.addingTimeInterval(120))
        precondition(partial.availableArmy == [.tideguard: 19, .tideMage: 2, .pillager: 4])
        precondition(partial.resources == Resources(wood: 42, amber: 42, provisions: 42),
            "Only expedition survivors carry loot; the garrison adds no capacity")
        let returned = partial
        partial.updateArmy(now: now.addingTimeInterval(121))
        precondition(partial == returned, "Returning troops and loot must not be duplicated")

        for infirmary in [false, true] {
            for sendsMage in [false, true] {
                var supported = base
                if infirmary { supported.buildings[10] = .infirmary }
                let selection: [ArmyUnit: Int] = sendsMage ? [.tideguard: 10, .tideMage: 1] : [.tideguard: 10]
                let expected = infirmary ? (sendsMage ? 0.05 : 0.1) : (sendsMage ? 0.15 : 0.2)
                precondition(supported.victoryLossRate(for: selection) == expected)
                precondition(supported.raid(targetID: 0, units: selection, now: now))
                precondition(supported.army?.raid?.victoryLossRate == expected)
                try storage.save(supported)
                supported = try storage.load(seed: 42, world: world, now: now)!
                supported.buildings = [12: .hall]
                supported.updateArmy(now: now.addingTimeInterval(120))
                let losses = infirmary ? (sendsMage ? 0 : 1) : (sendsMage ? 1 : 2)
                precondition(supported.availableArmy[.tideguard] == 20 - losses)
                precondition(supported.availableArmy[.tideMage] == 2)
            }
        }

        var defeated = base
        defeated.bots[0].level = 10
        precondition(defeated.raid(targetID: 0, units: [.tideguard: 1], now: now))
        defeated.updateArmy(now: now.addingTimeInterval(120))
        precondition(defeated.availableArmy == [.tideguard: 19, .tideMage: 2, .pillager: 4])
        precondition(defeated.resources == base.resources, "A strong garrison cannot win the deployed army's battle")

        var capacity = base
        capacity.army = ArmyState(units: [.tideguard: 100], unlockedUnits: [.tideguard])
        capacity.buildings[11] = .warCourt
        capacity.resources = Resources(wood: 1000, amber: 1000, provisions: 1000)
        precondition(capacity.raid(targetID: 0, units: [.tideguard: 60], now: now))
        precondition(capacity.availableArmy[.tideguard] == 40 && capacity.army?.isValid == true)
        precondition(!capacity.canTrain(.tideguard, count: 1), "The cap includes deployed troops")
        capacity.updateArmy(now: now.addingTimeInterval(120))
        precondition(capacity.availableArmy[.tideguard] == 88 && capacity.canTrain(.tideguard, count: 12))

        var all = base
        precondition(all.raid(targetID: 0, now: now))
        precondition(all.availableArmy.isEmpty && all.army?.raid?.units == base.availableArmy,
            "Existing callers still send all available troops")
        print("PASS: selected raid troops, saved garrison, mage support, invalid selections, losses, carrying and shared army cap")
    }
}
