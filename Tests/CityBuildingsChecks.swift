import Foundation

extension DomainChecks {
    static func checkCityBuildings() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let world = WorldMap(seed: 42)
        let suite = "CityBuildingsChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)

        var city = VillageState(seed: 42)
        city.resources = Resources(wood: 10_000, amber: 10_000, provisions: 10_000)
        city.resourceLevels = [0: 10, 2: 10, 4: 10]
        let plots = VillageMapMode.townCenter.slots.filter { $0 != 12 }
        precondition(BuildingKind.allCases.count == 12 && BuildingKind.constructible.count == plots.count)
        for (kind, plot) in zip(BuildingKind.constructible, plots) {
            let before = city.resources
            precondition(city.build(kind, at: plot, now: now))
            precondition(city.resources.wood == before.wood - kind.cost.wood)
            precondition(!city.build(kind, at: plot, now: now))
            city.updateConstruction(now: now.addingTimeInterval(60))
            precondition(city.hasBuilding(kind) && !city.canBuild(kind, at: plot))
        }
        precondition(city.buildings.count == 12)
        try storage.save(city)
        let loadedCity = try storage.load(seed: 42, world: world, now: now)
        precondition(loadedCity == city)

        // Version 10 allowed the quay on any urban lot. Preserve full villages by swapping.
        var inlandQuay = city
        inlandQuay.version = 10
        let displaced = inlandQuay.buildings[10]
        inlandQuay.buildings[10] = .expeditionQuay
        inlandQuay.buildings[23] = displaced
        let beforeMigration = inlandQuay.resources
        try storage.save(inlandQuay)
        let coastal = try storage.load(seed: 42, world: world, now: now)!
        precondition(coastal.version == VillageState.currentVersion && coastal.buildings[23] == .expeditionQuay)
        precondition(coastal.buildings[10] == displaced && coastal.buildings.count == 12)
        precondition(coastal.resources == beforeMigration)
        for plot in VillageMapMode.townCenter.slots {
            precondition(VillageState.canPlace(.expeditionQuay, at: plot) == (plot == 23))
            precondition(!VillageState.canPlace(.market, at: 23))
        }
        var quayJob = VillageState(seed: 42)
        quayJob.version = 10
        quayJob.buildings[23] = .market
        quayJob.construction = ConstructionJob(plot: 10, kind: .expeditionQuay, startedAt: now, duration: 60)
        try storage.save(quayJob)
        var loadedJob = try storage.load(seed: 42, world: world, now: now)!
        precondition(loadedJob.buildings[10] == .market && loadedJob.buildings[23] == nil)
        precondition(loadedJob.construction?.plot == 23 && loadedJob.construction?.endsAt == now.addingTimeInterval(60))
        loadedJob.updateConstruction(now: now.addingTimeInterval(60))
        precondition(loadedJob.buildings[23] == .expeditionQuay)
        var shoreJob = VillageState(seed: 42)
        shoreJob.version = 10
        shoreJob.construction = ConstructionJob(plot: 23, kind: .market, startedAt: now, duration: 60)
        try storage.save(shoreJob)
        let movedJob = try storage.load(seed: 42, world: world, now: now)!
        precondition(movedJob.construction?.plot == 10 && movedJob.construction?.endsAt == shoreJob.construction?.endsAt)
        var shoreBuilding = VillageState(seed: 42)
        shoreBuilding.version = 10
        shoreBuilding.buildings[23] = .market
        try storage.save(shoreBuilding)
        let movedBuilding = try storage.load(seed: 42, world: world, now: now)!
        precondition(movedBuilding.buildings[10] == .market && movedBuilding.buildings[23] == nil)

        var market = VillageState(seed: 42)
        precondition(!market.trade(from: .wood, to: .provisions, lots: 1))
        market.buildings[10] = .market
        for source in ResourceKind.allCases {
            for destination in ResourceKind.allCases where source != destination {
                market.resources = Resources(wood: 100, amber: 100, provisions: 100)
                let before = market.resources
                let received = 20 * source.tradeValue / (2 * destination.tradeValue)
                precondition(market.trade(from: source, to: destination, lots: 1))
                precondition(market.resources[source] == before[source] - 20)
                precondition(market.resources[destination] == before[destination] + received)
                precondition(market.resources[destination] * destination.tradeValue + market.resources[source] * source.tradeValue
                    < before[destination] * destination.tradeValue + before[source] * source.tradeValue)
            }
        }
        let beforeInvalid = market
        for lots in [Int.min, -1, 0, 11, Int.max] {
            precondition(!market.trade(from: .wood, to: .amber, lots: lots) && market == beforeInvalid)
        }
        precondition(!market.trade(from: .wood, to: .wood, lots: 1) && market == beforeInvalid)
        market.resources = Resources(wood: 19, amber: 299, provisions: 0)
        let insufficient = market
        precondition(!market.trade(from: .wood, to: .provisions, lots: 1) && market == insufficient)
        market.resources.wood = 20
        let full = market
        precondition(!market.trade(from: .wood, to: .amber, lots: 1) && market == full)
        market.resources.amber = 295
        precondition(market.trade(from: .wood, to: .amber, lots: 1) && market.resources.amber == 300)

        var forge = VillageState(seed: 42)
        forge.resources = Resources(wood: 1000, amber: 1000, provisions: 1000)
        precondition(!forge.upgradeWeapons(for: .reedrunner, now: now))
        forge.buildings[10] = .forge
        forge.buildingLevels = [.forge: 3]
        forge.army = ArmyState(units: [.reedrunner: 3])
        for level in 1...3 {
            let start = now.addingTimeInterval(Double(level * 600))
            let cost = forge.weaponUpgradeCost(for: .reedrunner)
            let stock = forge.resources
            precondition(forge.upgradeWeapons(for: .reedrunner, now: start))
            let end = forge.weaponUpgrade!.endsAt
            precondition(forge.resources == Resources(wood: stock.wood - cost.wood,
                amber: stock.amber - cost.amber, provisions: stock.provisions - cost.provisions))
            precondition(!forge.upgradeWeapons(for: .reedrunner, now: start))
            try storage.save(forge)
            forge = try storage.load(seed: 42, world: world, now: start)!
            forge.updateWeaponUpgrade(now: end.addingTimeInterval(-1))
            precondition(forge.weaponLevel(for: .reedrunner) == level - 1)
            forge.updateWeaponUpgrade(now: end)
            precondition(forge.weaponLevel(for: .reedrunner) == level && forge.armyPower == (5 + level) * 3)
        }
        let capped = forge
        precondition(!forge.upgradeWeapons(for: .reedrunner, now: now.addingTimeInterval(3000)) && forge == capped)
        forge.bots[0].level = 2
        forge.resources = Resources(wood: 0, amber: 0, provisions: 0)
        precondition(forge.raid(targetID: 0, now: now.addingTimeInterval(300)))
        forge.weaponsLevel = 0
        forge.unitWeaponLevels = nil
        forge.buildings = [12: .hall]
        forge.updateArmy(now: now.addingTimeInterval(420))
        precondition(forge.availableArmy[.reedrunner] == 3 && forge.resources.wood > 0,
            "The saved Forge bonus must turn a losing attack into a victory")

        for human in [false, true] {
            var transport = VillageState(seed: 42)
            transport.people = human ? .sauniers : nil
            transport.buildings[23] = .expeditionQuay
            transport.resources = Resources(wood: 0, amber: 0, provisions: 0)
            transport.army = ArmyState(units: [.tideguard: 3])
            precondition(transport.raid(targetID: 0, now: now))
            transport.updateArmy(now: now.addingTimeInterval(120))
            precondition(transport.resources.wood == (human ? 21 : 18),
                "Quay carrying bonus applies below the loot cap and adds to the human bonus")
        }

        var expedition = VillageState(seed: 42)
        expedition.people = .sauniers
        expedition.resources = Resources(wood: 0, amber: 0, provisions: 0)
        expedition.buildings[10] = .infirmary
        expedition.buildings[23] = .expeditionQuay
        expedition.buildings[13] = .forge
        expedition.weaponsLevel = 3
        expedition.army = ArmyState(units: [.tideguard: 30])
        precondition(expedition.raid(targetID: 0, now: now))
        precondition(expedition.army?.raid?.attackUpgrade == 3)
        precondition(expedition.army?.raid?.transportBonusPercent == 45)
        precondition(expedition.army?.isValid == true)
        try storage.save(expedition)
        expedition = try storage.load(seed: 42, world: world, now: now)!
        // Removing bonuses after departure must not change the saved expedition.
        expedition.buildings = [12: .hall]
        expedition.weaponsLevel = 0
        expedition.updateArmy(now: now.addingTimeInterval(120))
        precondition(expedition.availableArmy[.tideguard] == 30,
            "A decisive victory returns the whole force even when upgrades change during the expedition")
        precondition(expedition.resources == Resources(wood: 90, amber: 90, provisions: 90))
        let returned = expedition
        expedition.updateArmy(now: now.addingTimeInterval(121))
        precondition(expedition == returned)

        var defeated = VillageState(seed: 42)
        defeated.buildings[10] = .infirmary
        defeated.army = ArmyState(units: [.reedrunner: 10])
        defeated.bots[0].level = 10
        precondition(defeated.raid(targetID: 0, now: now))
        let stock = defeated.resources
        defeated.updateArmy(now: now.addingTimeInterval(120))
        precondition(defeated.availableArmy[.reedrunner] == 8 && defeated.resources == stock,
            "At an even power ratio, infirmary support lowers the loss rate to 14 percent")
        precondition(defeated.army?.raidReport?.won == false)
        precondition(defeated.army?.raidReport?.unitsSent == [.reedrunner: 10])
        precondition(defeated.army?.raidReport?.losses == [.reedrunner: 2])
        precondition(defeated.army?.raidReport?.stolen == Resources(wood: 0, amber: 0, provisions: 0))
        var mage = VillageState(seed: 42)
        mage.buildings[10] = .infirmary
        mage.army = ArmyState(units: [.tideMage: 20])
        precondition(mage.victoryLossRate == 0.05 && mage.raid(targetID: 0, now: now))
        mage.updateArmy(now: now.addingTimeInterval(120))
        precondition(mage.availableArmy[.tideMage] == 20,
            "A decisive victory with infirmary and mage support should not add a fixed casualty")

        var offline = VillageState(seed: 42)
        offline.lastProductionAt = now
        offline.lastBotExpansionAt = now
        offline.buildings[10] = .forge
        offline.bots[0].level = 2
        offline.army = ArmyState(units: [.reedrunner: 3])
        precondition(offline.upgradeWeapons(for: .reedrunner, now: now))
        precondition(offline.raid(targetID: 0, now: now))
        var online = offline
        for second in stride(from: 1, through: 120, by: 1) {
            _ = online.updateInRealTime(now: now.addingTimeInterval(Double(second)), on: world)
        }
        _ = offline.updateInRealTime(now: now.addingTimeInterval(120), on: world)
        precondition(offline.resources == online.resources && offline.army == online.army
            && offline.unitWeaponLevels == online.unitWeaponLevels && offline.weaponLevel(for: .reedrunner) == 1
            && offline.weaponUpgrade == online.weaponUpgrade)
        // Fractional accrual can differ by floating point rounding after 120 updates.
        precondition(abs(offline.productionRemainder!.wood - online.productionRemainder!.wood) < 1e-8)
        precondition(offline.availableArmy[.reedrunner] == 2,
            "An even-power raid applies the ratio-based defeat loss without changing its saved weapon level")

        var legacy = VillageState(seed: 42)
        legacy.version = 9
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(legacy)) as! [String: Any]
        json.removeValue(forKey: "weaponsLevel")
        json.removeValue(forKey: "weaponUpgrade")
        defaults.set(try JSONSerialization.data(withJSONObject: json), forKey: "village.v2.42")
        let migrated = try storage.load(seed: 42, world: world, now: now)!
        precondition(migrated.version == VillageState.currentVersion && migrated.weaponLevel == 0)
        var corrupt = capped
        corrupt.weaponUpgrade = WeaponUpgrade(targetLevel: 4, endsAt: now)
        try storage.save(corrupt)
        do {
            _ = try storage.load(seed: 42, world: world, now: now)
            preconditionFailure("An invalid weapon research must be rejected")
        } catch CocoaError.coderReadCorrupt { }
        print("PASS: twelve distinct buildings, atomic trades, weapon research, raid bonus snapshots, infirmary, quay and legacy saves")
    }
}
