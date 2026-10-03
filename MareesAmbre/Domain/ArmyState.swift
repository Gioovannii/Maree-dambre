import Foundation

struct ArmyState: Codable, Equatable {
    var units: [ArmyUnit: Int] = [:]
    var training: TrainingOrder?
    var raid: RaidOrder?
    var report: String?
    var raidedUntil: [Int: Date] = [:]
    var unlockedUnits: Set<ArmyUnit>?
    var research: TrainingOrder?

    var isValid: Bool {
        guard units.values.allSatisfy({ (0...100).contains($0) }),
              raidedUntil.allSatisfy({ (0...2).contains($0.key) && $0.value.timeIntervalSince1970.isFinite }) else { return false }
        if let training {
            guard (1...20).contains(training.count), training.endsAt.timeIntervalSince1970.isFinite else { return false }
        }
        if let research {
            guard research.count == 1, research.endsAt.timeIntervalSince1970.isFinite else { return false }
        }
        if let raid {
            guard (0...2).contains(raid.targetID), (14...92).contains(raid.defense),
                  raid.returnsAt.timeIntervalSince1970.isFinite,
                  raid.units.values.allSatisfy({ (0...100).contains($0) }),
                  raid.units.values.reduce(0, +) > 0 else { return false }
        }
        return units.values.reduce(0, +) + (training?.count ?? 0)
            + (raid?.units.values.reduce(0, +) ?? 0) <= 100
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
    var victoryLossRate: Double { availableArmy[.tideMage, default: 0] > 0 ? 0.15 : 0.2 }

    var unlockedUnits: Set<ArmyUnit> {
        if let unlocked = army?.unlockedUnits { return unlocked }
        // Preserve access to units already recruited in the previous prototype.
        var unlocked = Set(availableArmy.filter { $0.value > 0 }.map(\.key))
        if let training = army?.training { unlocked.insert(training.unit) }
        if let raid = army?.raid { unlocked.formUnion(raid.units.keys) }
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
        troops.research = TrainingOrder(unit: unit, count: 1, endsAt: now.addingTimeInterval(60))
        army = troops
        return true
    }
    var availableArmy: [ArmyUnit: Int] { army?.units ?? [:] }
    var armyPower: Int { availableArmy.reduce(0) { $0 + $1.key.attack * $1.value } }

    func canTrain(_ unit: ArmyUnit, count: Int) -> Bool {
        guard hasBuilding(.warCourt), unlockedUnits.contains(unit),
              (1...20).contains(count), army?.training == nil else { return false }
        let total = availableArmy.values.reduce(0, +) + (army?.raid?.units.values.reduce(0, +) ?? 0)
        return total + count <= 100 && resources.wood >= unit.cost.wood * count
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
        troops.training = TrainingOrder(unit: unit, count: count, endsAt: now.addingTimeInterval(Double(count * 30)))
        army = troops
        return true
    }

    func canRaid(_ bot: BotFaction, now: Date = .now) -> Bool {
        army?.raid == nil && armyPower > 0 && (army?.raidedUntil[bot.id] ?? .distantPast) <= now
            && bots.contains(where: { $0.id == bot.id })
    }

    @discardableResult
    mutating func raid(targetID: Int, now: Date = .now) -> Bool {
        updateArmy(now: now)
        guard let bot = bots.first(where: { $0.id == targetID }), canRaid(bot, now: now) else { return false }
        var troops = army ?? ArmyState()
        troops.raid = RaidOrder(targetID: bot.id, targetName: bot.name, units: troops.units,
                               defense: 10 + min(10, bot.level) * 4, returnsAt: now.addingTimeInterval(raidDuration))
        troops.units = [:]
        troops.raidedUntil[bot.id] = now.addingTimeInterval(raidDuration + 600)
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
            let power = raid.units.reduce(0) { $0 + $1.key.attack * $1.value }
            let won = power > raid.defense
            var losses = 0
            var capacity = 0
            for (unit, count) in raid.units {
                let lost = won ? min(count, max(0, Int(Double(count) * (raid.units[.tideMage, default: 0] > 0 ? 0.15 : 0.2)))) : (count + 1) / 2
                losses += lost
                troops.units[unit, default: 0] += count - lost
                capacity += (count - lost) * unit.carrying
            }
            let transport = people == .sauniers ? capacity * 120 / 100 : capacity
            let share = won ? min(60, transport / 3) : 0
            let wood = min(share, max(0, storageCapacity - resources.wood))
            let amber = min(share, max(0, storageCapacity - resources.amber))
            let provisions = min(share, max(0, storageCapacity - resources.provisions))
            resources.wood += wood
            resources.amber += amber
            resources.provisions += provisions
            troops.report = String(localized: "domain.army_state.value_against_value_value_losses_loot_stored_value_wood_value_amber_value_food", defaultValue: "\(String(won ? String(localized: "domain.army_state.victory", defaultValue: "Victoire") : String(localized: "domain.army_state.defeat", defaultValue: "Défaite"))) contre \(String(raid.targetDisplayName)). \(String(losses)) perte(s). Butin stocké : \(String(wood)) bois, \(String(amber)) ambre, \(String(provisions)) vivres.")
            troops.raid = nil
        }
        army = troops
    }
}
