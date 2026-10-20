import Foundation

struct ArmyState: Codable, Equatable {
    var units: [ArmyUnit: Int] = [:]
    var training: TrainingOrder?
    var raid: RaidOrder?
    var report: String?
    var raidReport: RaidReport?
    var raidedUntil: [Int: Date] = [:]
    var unlockedUnits: Set<ArmyUnit>?
    var research: TrainingOrder?
    var convoy: ConvoyOrder?

    var isValid: Bool {
        guard units.values.allSatisfy({ (0...100).contains($0) }),
              raidedUntil.allSatisfy({ (0...BotFaction.maximumStartingID).contains($0.key) && $0.value.timeIntervalSince1970.isFinite }) else { return false }
        guard convoy?.isValid ?? true else { return false }
        if let training {
            guard (1...20).contains(training.count), training.endsAt.timeIntervalSince1970.isFinite else { return false }
        }
        if let research {
            guard research.count == 1, research.endsAt.timeIntervalSince1970.isFinite else { return false }
        }
        if let raidReport, !raidReport.isValid { return false }
        if let raid {
            guard (0...BotFaction.maximumStartingID).contains(raid.targetID), (14...92).contains(raid.defense),
                  raid.returnsAt.timeIntervalSince1970.isFinite,
                  raid.units.values.allSatisfy({ (0...100).contains($0) }),
                  raid.units.values.reduce(0, +) > 0 else { return false }
            guard (0...3).contains(raid.attackUpgrade ?? 0),
                  (0...0.2).contains(raid.victoryLossRate ?? 0.2),
                  (0...0.8).contains(raid.defeatLossRate ?? 0.5),
                  (0...110).contains(raid.transportBonusPercent ?? 0),
                  (60...270).contains(raid.lootLimit ?? 60) else { return false }
            if let levels = raid.weaponLevels {
                guard Set(levels.keys) == Set(raid.units.keys),
                      levels.values.allSatisfy({ (0...GameProgression.maximumWeaponLevel).contains($0) }) else { return false }
            }
        }
        return units.values.reduce(0, +) + (training?.count ?? 0)
            + (raid?.units.values.reduce(0, +) ?? 0) + (convoy?.units.values.reduce(0, +) ?? 0) <= 100
    }
}

extension ArmyUnit {
    var researchCost: Resources {
        switch self {
        case .tideguard, .pillager: Resources(wood: 5, amber: 5, provisions: 5)
        case .reedrunner, .marshArcher: Resources(wood: 10, amber: 8, provisions: 10)
        case .amberSentry, .tideMage: Resources(wood: 15, amber: 15, provisions: 15)
        }
    }
    var cost: Resources {
        switch self {
        case .tideguard, .pillager: Resources(wood: 8, amber: 0, provisions: 10)
        case .reedrunner, .marshArcher: Resources(wood: 5, amber: 0, provisions: 8)
        case .amberSentry, .tideMage: Resources(wood: 6, amber: 3, provisions: 10)
        }
    }
    var attack: Int { switch self { case .tideguard: 8; case .reedrunner: 5; case .amberSentry: 12; case .pillager: 6; case .tideMage: 4; case .marshArcher: 10 } }
    var carrying: Int { switch self { case .tideguard: 15; case .reedrunner: 25; case .amberSentry: 12; case .pillager: 30; case .tideMage: 8; case .marshArcher: 12 } }
}

extension VillageState {
    var peopleUnits: [ArmyUnit] { ArmyUnit.allCases.filter { $0.people == (people ?? .sauniers) } }
    var trainableUnits: [ArmyUnit] { ArmyUnit.allCases.filter { peopleUnits.contains($0) || unlockedUnits.contains($0) } }
    var raidDuration: TimeInterval { people == .roseaux ? 90 : 120 }
    func raidDuration(to bot: BotFaction) -> TimeInterval {
        let distance = location == .home ? (bot.id < 3 ? 0 : bot.distanceFromHome) : location.distance(to: bot.capital)
        return raidDuration + ceil(TimeInterval(distance * 2) * distantRaidDurationMultiplier)
    }
    var victoryLossRate: Double { victoryLossRate(for: availableArmy) }
    func victoryLossRate(for units: [ArmyUnit: Int]) -> Double {
        let mage = units[.tideMage, default: 0] > 0
        guard hasBuilding(.infirmary) else { return mage ? 0.15 : 0.2 }
        return max(0.01, 0.1 - 0.005 * Double(buildingLevel(.infirmary) - 1) - (mage ? 0.05 : 0))
    }
    var defeatLossRate: Double { hasBuilding(.infirmary) ? 0.35 - 0.01 * Double(buildingLevel(.infirmary) - 1) : 0.5 }
    var transportBonusPercent: Int { (people == .sauniers ? 20 : 0) + (hasBuilding(.expeditionQuay) ? 25 + 5 * (buildingLevel(.expeditionQuay) - 1) : 0) + specialtyTransportBonus }
    var raidLootLimit: Int { hasBuilding(.expeditionQuay) ? 90 + 20 * (buildingLevel(.expeditionQuay) - 1) : 60 }
    func attackStrength(of unit: ArmyUnit) -> Int { unit.attack + weaponLevel(for: unit) }
    func defenseStrength(of unit: ArmyUnit) -> Int { unit.defense + weaponLevel(for: unit) }

    var unlockedUnits: Set<ArmyUnit> {
        if let unlocked = army?.unlockedUnits { return unlocked }
        // Preserve access to units already recruited in the previous prototype.
        var unlocked = Set(availableArmy.filter { $0.value > 0 }.map(\.key))
        if let training = army?.training { unlocked.insert(training.unit) }
        if let raid = army?.raid { unlocked.formUnion(raid.units.keys) }
        if let convoy = army?.convoy { unlocked.formUnion(convoy.units.keys) }
        if let shipment { unlocked.formUnion(shipment.units.keys) }
        if let escort = expansion?.voyage?.escort { unlocked.insert(escort) }
        return unlocked
    }

    func canResearch(_ unit: ArmyUnit) -> Bool {
        peopleUnits.contains(unit) && hasBuilding(.academy) && army?.research == nil && !unlockedUnits.contains(unit)
            && resources.wood >= unit.researchCost.wood && resources.amber >= unit.researchCost.amber
            && resources.provisions >= unit.researchCost.provisions
    }

    @discardableResult
    mutating func research(_ unit: ArmyUnit, now: Date = .now) -> Bool {
        updateArmy(now: now)
        guard canResearch(unit) else { return false }
        resources.wood -= unit.researchCost.wood
        resources.amber -= unit.researchCost.amber
        resources.provisions -= unit.researchCost.provisions
        var troops = army ?? ArmyState()
        troops.unlockedUnits = unlockedUnits
        troops.research = TrainingOrder(unit: unit, count: 1, endsAt: now.addingTimeInterval(unitResearchDuration))
        army = troops
        return true
    }
    var availableArmy: [ArmyUnit: Int] { army?.units ?? [:] }
    var armyPower: Int { armyPower(for: availableArmy) }
    func armyPower(for units: [ArmyUnit: Int]) -> Int {
        units.reduce(0) { $0 + attackStrength(of: $1.key) * $1.value }
    }

    func canTrain(_ unit: ArmyUnit, count: Int) -> Bool {
        guard hasBuilding(.warCourt), unlockedUnits.contains(unit),
              (1...20).contains(count), army?.training == nil else { return false }
        let total = availableArmy.values.reduce(0, +) + (army?.raid?.units.values.reduce(0, +) ?? 0)
            + (army?.convoy?.units.values.reduce(0, +) ?? 0)
        return total + foundingEscortCount + shipmentEscortCount + count <= 100 && resources.wood >= unit.cost.wood * count
            && resources.amber >= unit.cost.amber * count && resources.provisions >= unit.cost.provisions * count
    }

    @discardableResult
    mutating func train(_ unit: ArmyUnit, count: Int, now: Date = .now) -> Bool {
        updateArmy(now: now)
        guard canTrain(unit, count: count) else { return false }
        resources.wood -= unit.cost.wood * count
        resources.amber -= unit.cost.amber * count
        resources.provisions -= unit.cost.provisions * count
        var troops = army ?? ArmyState()
        troops.training = TrainingOrder(unit: unit, count: count, endsAt: now.addingTimeInterval(ceil(Double(count) * trainingSecondsPerUnit)))
        army = troops
        return true
    }

    func canRaid(_ bot: BotFaction, units: [ArmyUnit: Int]? = nil, now: Date = .now) -> Bool {
        let selected = units ?? availableArmy
        guard army?.raid == nil, (army?.raidedUntil[bot.id] ?? .distantPast) <= now,
              bots.contains(where: { $0.id == bot.id }),
              selected.values.contains(where: { $0 > 0 }),
              selected.allSatisfy({ $0.value >= 0 && $0.value <= availableArmy[$0.key, default: 0] }) else {
            return false
        }
        return armyPower(for: selected) > 0
    }

    @discardableResult
    mutating func raid(targetID: Int, units: [ArmyUnit: Int]? = nil, now: Date = .now) -> Bool {
        updateWeaponUpgrade(now: now)
        updateArmy(now: now)
        guard let bot = bots.first(where: { $0.id == targetID }), canRaid(bot, units: units, now: now) else { return false }
        let deployed = (units ?? availableArmy).filter { $0.value > 0 }
        var troops = army ?? ArmyState()
        let duration = raidDuration(to: bot)
        let attackPower = armyPower(for: deployed)
        let defense = 10 + min(10, bot.level) * 4
        let victorySupport = victoryLossRate(for: deployed) / 0.2
        let defeatSupport = defeatLossRate / 0.5
        troops.raid = RaidOrder(targetID: bot.id, targetName: bot.pseudonym(seed: seed), units: deployed,
                               defense: defense, returnsAt: now.addingTimeInterval(duration),
                               attackUpgrade: weaponLevel,
                               victoryLossRate: RaidOrder.casualtyRate(attackPower: attackPower, defense: defense,
                                                                      won: true, supportMultiplier: victorySupport),
                               defeatLossRate: RaidOrder.casualtyRate(attackPower: attackPower, defense: defense,
                                                                     won: false, supportMultiplier: defeatSupport),
                               transportBonusPercent: transportBonusPercent, lootLimit: raidLootLimit,
                               weaponLevels: Dictionary(uniqueKeysWithValues: deployed.keys.map { ($0, weaponLevel(for: $0)) }))
        for (unit, count) in deployed {
            let remaining = troops.units[unit, default: 0] - count
            if remaining == 0 { troops.units.removeValue(forKey: unit) }
            else { troops.units[unit] = remaining }
        }
        troops.raidedUntil[bot.id] = now.addingTimeInterval(duration + 600)
        army = troops
        return true
    }

    mutating func updateArmy(now: Date = .now) {
        guard var troops = army else { return }
        if troops.unlockedUnits == nil { troops.unlockedUnits = unlockedUnits }
        if let research = troops.research, now >= research.endsAt {
            troops.unlockedUnits?.insert(research.unit)
            troops.research = nil
        }
        if let order = troops.training, now >= order.endsAt {
            troops.units[order.unit, default: 0] += order.count
            troops.training = nil
        }
        if let raid = troops.raid, now >= raid.returnsAt {
            let power = raid.attackPower
            let won = power > raid.defense
            // Older in-flight raids may still carry a fixed casualty rate from a
            // previous ruleset. Keep any faction/building support already saved,
            // while ensuring decisive victories use the current power-ratio rule.
            let victoryRate = min(raid.victoryLossRate ?? 0.2,
                RaidOrder.casualtyRate(attackPower: power, defense: raid.defense, won: true))
            let defeatRate = min(raid.defeatLossRate ?? 0.5,
                RaidOrder.casualtyRate(attackPower: power, defense: raid.defense, won: false))
            let lossesByUnit = RaidOrder.casualties(units: raid.units,
                                                     rate: won ? victoryRate : defeatRate,
                                                     roundUp: !won)
            let losses = lossesByUnit.values.reduce(0, +)
            var capacity = 0
            for (unit, count) in raid.units {
                let lost = lossesByUnit[unit, default: 0]
                troops.units[unit, default: 0] += count - lost
                capacity += (count - lost) * unit.carrying
            }
            let bonus = raid.transportBonusPercent ?? (people == .sauniers ? 20 : 0)
            let transport = capacity * (100 + bonus) / 100
            let share = won ? min(raid.lootLimit ?? 60, transport / 3) : 0
            let wood = min(share, max(0, storageCapacity - resources.wood))
            let amber = min(share, max(0, storageCapacity - resources.amber))
            let provisions = min(share, max(0, storageCapacity - resources.provisions))
            resources.wood += wood
            resources.amber += amber
            resources.provisions += provisions
            troops.raidReport = RaidReport(targetName: raid.targetDisplayName, attackPower: power,
                                           defensePower: raid.defense, unitsSent: raid.units,
                                           losses: lossesByUnit,
                                           stolen: Resources(wood: wood, amber: amber, provisions: provisions))
            troops.report = String(localized: "domain.army_state.combat_report", defaultValue: "\(String(won ? String(localized: "domain.army_state.victory", defaultValue: "Victoire") : String(localized: "domain.army_state.defeat", defaultValue: "Défaite"))) contre \(String(raid.targetDisplayName)). Forces : \(String(power)) en attaque contre \(String(raid.defense)) en défense. \(String(losses)) perte(s). Butin stocké : \(String(wood)) bois, \(String(amber)) ambre, \(String(provisions)) vivres.")
            if let report = troops.raidReport {
                receiveMail(.raid(report), key: "raid.\(raid.targetID).\(raid.returnsAt.timeIntervalSinceReferenceDate)", at: raid.returnsAt)
            }
            troops.raid = nil
        }
        army = troops
    }
}
