import Foundation

extension DomainChecks {
    static func checkProgression() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let world = WorldMap(seed: 42)
        let suite = "ProgressionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)

        var city = VillageState(seed: 42)
        city.lastProductionAt = now
        city.lastBotExpansionAt = now
        city.people = .sauniers
        city.resources = Resources(wood: 100_000, amber: 100_000, provisions: 100_000)
        city.resourceLevels = [0: 10, 2: 10, 4: 10]
        let plots = VillageMapMode.townCenter.slots.filter { $0 != 12 }
        city.buildings = Dictionary(uniqueKeysWithValues: zip(plots, BuildingKind.constructible))
        city.buildings[12] = .hall
        city.army = ArmyState(units: [.tideguard: 3, .pillager: 3], unlockedUnits: [.tideguard, .pillager])

        // An upgrade is atomic, keeps the old effect, shares the builder and cannot move.
        let warehousePlot = city.buildings.first { $0.value == .warehouse }!.key
        let oldCapacity = city.storageCapacity
        let oldStock = city.resources
        precondition(city.upgradeBuilding(at: warehousePlot, now: now))
        let job = city.construction!
        precondition(job.level == 2 && job.duration > 60 && city.storageCapacity == oldCapacity)
        precondition(city.resources.wood == oldStock.wood - job.cost.wood)
        let pending = city
        precondition(!city.upgradeBuilding(at: 12, now: now) && !city.developResource(at: 1, now: now))
        precondition(!city.canMoveBuilding(from: warehousePlot, to: 22) && city == pending)
        try storage.save(city)
        city = try storage.load(seed: 42, world: world, now: now)!
        city.updateConstruction(now: job.endsAt.addingTimeInterval(-1))
        precondition(city.storageCapacity == oldCapacity)
        city.updateConstruction(now: job.endsAt)
        precondition(city.storageCapacity == oldCapacity + 500 && city.buildingLevel(.warehouse) == 2)
        let completed = city
        city.updateConstruction(now: job.endsAt.addingTimeInterval(1))
        precondition(city == completed)

        // Cancellation refunds the price actually paid and preserves the existing building.
        precondition(city.upgradeBuilding(at: warehousePlot, now: job.endsAt))
        let canceledJob = city.construction!
        let paidStock = city.resources
        _ = city.cancelConstruction(now: job.endsAt.addingTimeInterval(1))
        precondition(city.resources.wood == paidStock.wood + canceledJob.cost.wood / 2)
        precondition(city.buildingLevel(.warehouse) == 2 && city.buildings[warehousePlot] == .warehouse)

        // Hall is upgradeable in place; old timers are snapshots, not recalculated durations.
        precondition(city.upgradeBuilding(at: 12, now: now))
        try storage.save(city)
        var hall = try storage.load(seed: 42, world: world, now: now)!
        let hallEnd = hall.construction!.endsAt
        hall.updateConstruction(now: hallEnd)
        precondition(hall.buildingLevel(.hall) == 2 && hall.constructionDuration(for: 2) < job.duration)

        // Every building has increasing costs/durations, a level cap and a meaningful effect.
        for kind in BuildingKind.allCases {
            var upgraded = completed
            let plot = upgraded.buildings.first { $0.value == kind }!.key
            var time = now
            for target in (upgraded.buildingLevel(kind) + 1)...GameProgression.maximumBuildingLevel {
                precondition(upgraded.upgradeBuilding(at: plot, now: time))
                let upgrade = upgraded.construction!
                precondition(upgrade.cost.wood > kind.cost(for: target - 1).wood)
                precondition(upgraded.buildingEffect(kind, level: target) != upgraded.buildingEffect(kind, level: target - 1))
                time = upgrade.endsAt
                upgraded.updateConstruction(now: time)
            }
            precondition(!upgraded.canUpgradeBuilding(at: plot) && upgraded.buildingLevel(kind) == 10)
            try storage.save(upgraded)
            let restored = try storage.load(seed: 42, world: world, now: time)
            precondition(restored == upgraded)
        }
        for kind in ResourceSiteKind.allCases {
            for target in 2...10 {
                precondition(kind.cost(for: target).wood > kind.cost(for: target - 1).wood)
                precondition(completed.resourceUpgradeDuration(for: target) > completed.resourceUpgradeDuration(for: target - 1))
            }
        }
        for target in 2...10 {
            // The warehouse never requires more storage than its previous level offers.
            let cost = BuildingKind.warehouse.cost(for: target)
            precondition(max(cost.wood, cost.amber, cost.provisions) <= 300 + 500 * (target - 1))
        }
        // Storage can fund every progression tier, including its own next level.
        let maximumCapacity = 300 + 500 * GameProgression.maximumBuildingLevel
        for target in 1...10 {
            let costs = BuildingKind.allCases.map { $0.cost(for: target) }
                + ResourceSiteKind.allCases.map { $0.cost(for: target) }
                + [GameProgression.scaled(Resources(wood: 40, amber: 20, provisions: 30), level: target, growth: 1.6)]
            precondition(costs.allSatisfy { max($0.wood, $0.amber, $0.provisions) <= maximumCapacity })
        }

        var weapons = completed
        weapons.buildingLevels = [.forge: 10]
        precondition(weapons.upgradeWeapons(for: .tideguard, now: now))
        let researchEnd = weapons.weaponUpgrade!.endsAt
        precondition(weapons.weaponLevel(for: .tideguard) == 0 && weapons.weaponLevel(for: .pillager) == 0)
        precondition(!weapons.upgradeWeapons(for: .pillager, now: now))
        weapons.updateWeaponUpgrade(now: researchEnd)
        precondition(weapons.weaponLevel(for: .tideguard) == 1 && weapons.weaponLevel(for: .pillager) == 0)
        precondition(weapons.attackStrength(of: .tideguard) == ArmyUnit.tideguard.attack + 1)
        precondition(weapons.defenseStrength(of: .pillager) == ArmyUnit.pillager.defense)
        precondition(!weapons.canUpgradeWeapons(for: .tideMage), "Unlock a unit before researching its weapons")
        let forgePlot = weapons.buildings.first { $0.value == .forge }!.key
        weapons.buildingLevels?[.forge] = 1
        precondition(!weapons.canUpgradeWeapons(for: .tideguard), "Forge level gates the next weapon tier")
        weapons.buildingLevels?[.forge] = 10

        // Raid and convoy equipment is captured by unit, and remains valid after new research.
        precondition(weapons.raid(targetID: 0, units: [.tideguard: 1, .pillager: 1], now: now))
        let raid = weapons.army!.raid!
        precondition(raid.weaponLevels == [.tideguard: 1, .pillager: 0] && weapons.army!.isValid)
        weapons.unitWeaponLevels = [.tideguard: 10, .pillager: 10]
        weapons.updateArmy(now: raid.returnsAt)
        precondition(weapons.army?.report != nil)
        var convoy = completed
        convoy.coastalCampaign = CoastalCampaign()
        convoy.unitWeaponLevels = [.tideguard: 2, .pillager: 0]
        precondition(convoy.sendConvoy(on: .crossing, units: [.tideguard: 2, .pillager: 1]))
        let order = convoy.army!.convoy!
        precondition(order.weaponLevels == [.tideguard: 2, .pillager: 0] && order.isValid)
        let power = order.power
        convoy.unitWeaponLevels = [.tideguard: 10, .pillager: 10]
        precondition(convoy.army!.convoy!.power == power)

        var specialist = completed
        specialist.buildingLevels = [.forge: 10]
        var researchTime = now
        for target in 1...10 {
            precondition(specialist.upgradeWeapons(for: .tideguard, now: researchTime))
            let end = specialist.weaponUpgrade!.endsAt
            if target > 1 { precondition(end.timeIntervalSince(researchTime) > 60) }
            specialist.updateWeaponUpgrade(now: end)
            researchTime = end
            precondition(specialist.weaponLevel(for: .tideguard) == target && specialist.weaponLevel(for: .pillager) == 0)
        }
        precondition(!specialist.canUpgradeWeapons(for: .tideguard))
        specialist.buildingLevels?[.infirmary] = 10
        specialist.buildingLevels?[.expeditionQuay] = 10
        precondition(specialist.raid(targetID: 0, now: researchTime))
        precondition(specialist.army!.isValid && specialist.army!.raid!.lootLimit == 270)
        try storage.save(specialist)
        let restoredSpecialist = try storage.load(seed: 42, world: world, now: researchTime)!
        precondition(restoredSpecialist == specialist)

        var field = VillageState(seed: 42)
        field.resourceLevels = [0: 1]
        precondition(field.developResource(at: 0, now: now))
        precondition(field.resourceUpgrade!.effectiveDuration > 60)
        try storage.save(field)
        var restoredField = try storage.load(seed: 42, world: world, now: now)!
        let fieldEnd = restoredField.resourceUpgrade!.endsAt
        restoredField.updateResourceUpgrade(now: fieldEnd.addingTimeInterval(-1))
        precondition(restoredField.resourceLevel(at: 0) == 1)
        restoredField.updateResourceUpgrade(now: fieldEnd)
        precondition(restoredField.resourceLevel(at: 0) == 2)

        var advancedMarket = completed
        advancedMarket.buildingLevels = [.market: 10]
        advancedMarket.resources = Resources(wood: 100, amber: 0, provisions: 0)
        precondition(advancedMarket.trade(from: .wood, to: .amber, lots: 5))
        let amberLots = advancedMarket.resources.amber / 20
        precondition(advancedMarket.trade(from: .amber, to: .wood, lots: amberLots))
        precondition(advancedMarket.resources.wood < 100, "No profitable exchange cycle at the highest market level")

        // Version 13 paid jobs retain both their deadline and their legacy cost after resaving.
        var legacy = VillageState(seed: 42)
        legacy.version = 13
        legacy.resourceLevels = [0: 4]
        legacy.resourceUpgrade = ResourceUpgrade(plot: 0, targetLevel: 5, startedAt: now,
                                                cost: ResourceSiteKind.woodland.legacyCost(for: 5))
        try storage.save(legacy)
        var migrated = try storage.load(seed: 42, world: world, now: now)!
        try storage.save(migrated)
        migrated = try storage.load(seed: 42, world: world, now: now)!
        precondition(migrated.resourceUpgrade!.endsAt == now.addingTimeInterval(60))
        migrated.updateResourceUpgrade(now: now.addingTimeInterval(60))
        precondition(migrated.resourceLevel(at: 0) == 5)
        legacy.resourceUpgrade = nil
        legacy.buildings[forgePlot] = .forge
        legacy.weaponsLevel = 2
        legacy.weaponUpgrade = WeaponUpgrade(targetLevel: 3, endsAt: now.addingTimeInterval(60))
        try storage.save(legacy)
        migrated = try storage.load(seed: 42, world: world, now: now)!
        migrated.updateWeaponUpgrade(now: now.addingTimeInterval(60))
        precondition(ArmyUnit.allCases.allSatisfy { migrated.weaponLevel(for: $0) == 3 })

        // Offline completion accrues the previous production rate until the exact deadline.
        var offline = completed
        offline.resources = Resources(wood: 100, amber: 100, provisions: 100)
        offline.lastProductionAt = now
        offline.productionRemainder = .zero
        precondition(offline.upgradeBuilding(at: 12, now: now))
        let end = offline.construction!.endsAt.addingTimeInterval(3600)
        var online = offline
        for second in 1...Int(end.timeIntervalSince(now)) {
            _ = online.updateInRealTime(now: now.addingTimeInterval(Double(second)), on: world)
        }
        _ = offline.updateInRealTime(now: end, on: world)
        precondition(offline.resources == online.resources && offline.buildingLevels == online.buildingLevels)

        for invalidLevel in [-1, 0, 11, Int.max] {
            var corrupt = completed
            corrupt.buildingLevels = [.warehouse: invalidLevel]
            let data = try JSONEncoder().encode(corrupt)
            defaults.set(data, forKey: "village.v2.42")
            do {
                _ = try storage.load(seed: 42, world: world, now: now)
                preconditionFailure("Corrupt building level accepted")
            } catch CocoaError.coderReadCorrupt {}
            precondition(defaults.data(forKey: "village.v2.42") == data)
        }
        print("PASS: building levels/effects, paid refunds, growing costs/timers, per-unit weapons, legacy jobs and offline completion")
    }
}
