import Foundation

extension DomainChecks {
    static func checkRaidSelection() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var specialty = VillageState(seed: 42)
        specialty.people = .sauniers
        let carryingBefore = specialty.transportBonusPercent
        specialty.buildings[10] = .market
        precondition(specialty.transportBonusPercent == carryingBefore + 5)
        specialty.buildingLevels = [.market: 10]
        precondition(specialty.specialtyTransportBonus == 20)
        specialty.people = .nacre
        specialty.buildings[11] = .watchtower
        precondition(specialty.specialtyDefenseBonus == 5)
        specialty.people = .roseaux
        let distantTarget = specialty.bots[9]
        let beforeAcademy = specialty.raidDuration(to: distantTarget)
        specialty.buildings[13] = .academy
        precondition(specialty.raidDuration(to: distantTarget) < beforeAcademy)
        precondition(specialty.raidDuration(to: specialty.bots[0]) == specialty.raidDuration)
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
        let mixedSmallForce: [ArmyUnit: Int] = [.tideguard: 1, .pillager: 1, .tideMage: 1, .marshArcher: 1]
        let mixedDefeatLosses = RaidOrder.casualties(units: mixedSmallForce, rate: 0.5, roundUp: true)
        precondition(mixedDefeatLosses.values.reduce(0, +) == 2,
            "Defeat losses round once across the whole force instead of wiping every small unit type")
        precondition(mixedDefeatLosses.values.allSatisfy { $0 <= 1 },
            "A small mixed force should not lose multiple copies of a type it only sent once")
        precondition(RaidOrder.casualties(units: mixedSmallForce, rate: 0.2, roundUp: false).isEmpty,
            "Victory loss rounding applies to the total force, not each unit type")
        precondition(RaidOrder.casualtyRate(attackPower: 200, defense: 40, won: true) == 0,
            "An overwhelmingly strong raid should not lose troops to a fixed victory tax")
        let overwhelmingPower = 445
        let smallDefense = 30
        let overwhelmingLossRate = RaidOrder.casualtyRate(
            attackPower: overwhelmingPower, defense: smallDefense, won: true)
        precondition(overwhelmingLossRate == 0
            && RaidOrder.casualties(units: [.reedrunner: 40], rate: overwhelmingLossRate, roundUp: false).isEmpty,
            "A 445-power raid against 30 defense should not lose troops on victory")
        precondition(abs(RaidOrder.casualtyRate(attackPower: 80, defense: 50, won: true) - 0.16) < 0.0001,
            "A close victory should still carry some risk")
        precondition(RaidOrder.casualtyRate(attackPower: 10, defense: 50, won: false)
            > RaidOrder.casualtyRate(attackPower: 40, defense: 50, won: false),
            "Being heavily outmatched should cost more than a narrow defeat")
        var unknown = base
        precondition(!unknown.raid(targetID: 99, units: [.tideguard: 2], now: now) && unknown == base)

        var partial = base
        precondition(partial.armyPower(for: [.tideguard: 8]) == 64)
        precondition(partial.raid(targetID: 0, units: [.tideguard: 8, .tideMage: 0], now: now))
        precondition(partial.army?.raid?.units == [.tideguard: 8])
        precondition(partial.availableArmy == [.tideguard: 12, .tideMage: 2, .pillager: 4])
        precondition(partial.army?.raid?.victoryLossRate == 0, "A decisive raid should have no fixed casualty tax")
        precondition(partial.army?.isValid == true)
        let underway = partial
        precondition(!partial.raid(targetID: 1, units: [.tideguard: 2], now: now) && partial == underway)
        try storage.save(partial)
        partial = try storage.load(seed: 42, world: world, now: now)!
        precondition(partial == underway, "Selection and garrison must survive relaunch")
        partial.updateArmy(now: now.addingTimeInterval(119))
        precondition(partial.army?.raid != nil && partial.availableArmy == underway.availableArmy)
        partial.updateArmy(now: now.addingTimeInterval(120))
        precondition(partial.availableArmy == [.tideguard: 20, .tideMage: 2, .pillager: 4])
        precondition(partial.resources == Resources(wood: 48, amber: 48, provisions: 48),
            "Only expedition survivors carry loot; the garrison adds no capacity")
        let returned = partial
        partial.updateArmy(now: now.addingTimeInterval(121))
        precondition(partial == returned, "Returning troops and loot must not be duplicated")

        var inFlightLegacyRaid = base
        inFlightLegacyRaid.army?.raid = RaidOrder(targetID: 0, targetName: "Liora",
            units: [.tideguard: 40], defense: smallDefense, returnsAt: now,
            victoryLossRate: 0.2, defeatLossRate: 0.5)
        inFlightLegacyRaid.army?.units = [:]
        inFlightLegacyRaid.updateArmy(now: now)
        precondition(inFlightLegacyRaid.availableArmy[.tideguard] == 40,
            "An in-flight raid saved with the old fixed loss rate must use the decisive-victory rule when it returns")

        for infirmary in [false, true] {
            for sendsMage in [false, true] {
                var supported = base
                if infirmary { supported.buildings[10] = .infirmary }
                let selection: [ArmyUnit: Int] = sendsMage ? [.tideguard: 10, .tideMage: 1] : [.tideguard: 10]
                let supportRate = infirmary ? (sendsMage ? 0.05 : 0.1) : (sendsMage ? 0.15 : 0.2)
                let expected = RaidOrder.casualtyRate(attackPower: supported.armyPower(for: selection),
                    defense: 50, won: true, supportMultiplier: supportRate / 0.2)
                supported.bots[0].level = 10
                precondition(supported.victoryLossRate(for: selection) == supportRate)
                precondition(supported.raid(targetID: 0, units: selection, now: now))
                precondition(supported.army?.raid?.victoryLossRate == expected)
                try storage.save(supported)
                supported = try storage.load(seed: 42, world: world, now: now)!
                supported.buildings = [12: .hall]
                supported.updateArmy(now: now.addingTimeInterval(120))
                let losses = RaidOrder.casualties(units: selection, rate: expected, roundUp: false)
                precondition(supported.availableArmy[.tideguard] == 20 - losses[.tideguard, default: 0])
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
        precondition(capacity.availableArmy[.tideguard] == 100 && !capacity.canTrain(.tideguard, count: 1),
            "A decisive raid preserves the full force and does not create artificial training capacity")

        var all = base
        precondition(all.raid(targetID: 0, now: now))
        precondition(all.availableArmy.isEmpty && all.army?.raid?.units == base.availableArmy,
            "Existing callers still send all available troops")
        print("PASS: selected raid troops, saved garrison, mage support, invalid selections, losses, carrying and shared army cap")
    }
}
