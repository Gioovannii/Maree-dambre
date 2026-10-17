import Foundation

extension VillageState {
    static let maximumWeaponLevel = GameProgression.maximumWeaponLevel
    // Legacy village-wide research remains a fallback for existing saves.
    var weaponLevel: Int { weaponsLevel ?? 0 }

    func weaponLevel(for unit: ArmyUnit) -> Int {
        max(weaponLevel, unitWeaponLevels?[unit] ?? 0)
    }

    func weaponUpgradeCost(for unit: ArmyUnit) -> Resources {
        GameProgression.scaled(Resources(wood: 40, amber: 20, provisions: 30),
                               level: weaponLevel(for: unit) + 1, growth: 1.6)
    }

    func weaponUpgradeDuration(for unit: ArmyUnit) -> TimeInterval {
        ceil(GameProgression.duration(level: weaponLevel(for: unit) + 1, growth: 1.5)
             / (1 + 0.04 * Double(max(0, buildingLevel(.academy) - 1))))
    }

    func canUpgradeWeapons(for unit: ArmyUnit) -> Bool {
        let cost = weaponUpgradeCost(for: unit)
        let next = weaponLevel(for: unit) + 1
        return unlockedUnits.contains(unit) && next <= Self.maximumWeaponLevel
            && buildingLevel(.forge) >= next && weaponUpgrade == nil
            && resources.wood >= cost.wood && resources.amber >= cost.amber && resources.provisions >= cost.provisions
    }

    @discardableResult
    mutating func upgradeWeapons(for unit: ArmyUnit, now: Date = .now) -> Bool {
        updateWeaponUpgrade(now: now)
        guard canUpgradeWeapons(for: unit) else { return false }
        let cost = weaponUpgradeCost(for: unit)
        resources.wood -= cost.wood
        resources.amber -= cost.amber
        resources.provisions -= cost.provisions
        weaponUpgrade = WeaponUpgrade(targetLevel: weaponLevel(for: unit) + 1,
                                      endsAt: now.addingTimeInterval(weaponUpgradeDuration(for: unit)), unit: unit)
        return true
    }

    mutating func updateWeaponUpgrade(now: Date = .now) {
        guard let job = weaponUpgrade, now >= job.endsAt else { return }
        if let unit = job.unit {
            var levels = unitWeaponLevels ?? [:]
            levels[unit] = job.targetLevel
            unitWeaponLevels = levels
        } else {
            // Finish a pre-update global research without losing its paid benefit.
            weaponsLevel = job.targetLevel
            if var levels = unitWeaponLevels {
                for unit in levels.keys { levels[unit] = max(levels[unit, default: 0], job.targetLevel) }
                unitWeaponLevels = levels
            }
        }
        weaponUpgrade = nil
    }

    func tradeReturn(from source: ResourceKind, to destination: ResourceKind, lots: Int) -> Int {
        guard source != destination, (1...10).contains(lots) else { return 0 }
        return Int(floor(Double(lots * 20 * source.tradeValue) * tradeEfficiency / Double(destination.tradeValue)))
    }

    var tradeEfficiency: Double { 0.5 + 0.025 * Double(max(0, buildingLevel(.market) - 1)) }

    func canTrade(from source: ResourceKind, to destination: ResourceKind, lots: Int) -> Bool {
        let received = tradeReturn(from: source, to: destination, lots: lots)
        return hasBuilding(.market) && received > 0 && resources[source] >= lots * 20
            && resources[destination] <= storageCapacity - received
    }

    @discardableResult
    mutating func trade(from source: ResourceKind, to destination: ResourceKind, lots: Int) -> Bool {
        guard canTrade(from: source, to: destination, lots: lots) else { return false }
        resources[source] -= lots * 20
        resources[destination] += tradeReturn(from: source, to: destination, lots: lots)
        return true
    }
}
