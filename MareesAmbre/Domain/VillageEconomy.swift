import Foundation

extension VillageState {
    static let maximumWeaponLevel = 3
    var weaponLevel: Int { weaponsLevel ?? 0 }
    var weaponUpgradeCost: Resources {
        let level = weaponLevel + 1
        return Resources(wood: 40 * level, amber: 20 * level, provisions: 30 * level)
    }
    var canUpgradeWeapons: Bool {
        let cost = weaponUpgradeCost
        return hasBuilding(.forge) && weaponLevel < Self.maximumWeaponLevel && weaponUpgrade == nil
            && resources.wood >= cost.wood && resources.amber >= cost.amber && resources.provisions >= cost.provisions
    }

    @discardableResult
    mutating func upgradeWeapons(now: Date = .now) -> Bool {
        updateWeaponUpgrade(now: now)
        guard canUpgradeWeapons else { return false }
        let cost = weaponUpgradeCost
        resources.wood -= cost.wood
        resources.amber -= cost.amber
        resources.provisions -= cost.provisions
        weaponUpgrade = WeaponUpgrade(targetLevel: weaponLevel + 1, endsAt: now.addingTimeInterval(60))
        return true
    }

    mutating func updateWeaponUpgrade(now: Date = .now) {
        guard let job = weaponUpgrade, now >= job.endsAt else { return }
        weaponsLevel = job.targetLevel
        weaponUpgrade = nil
    }

    func tradeReturn(from source: ResourceKind, to destination: ResourceKind, lots: Int) -> Int {
        guard source != destination, (1...10).contains(lots) else { return 0 }
        return lots * 20 * source.tradeValue / (destination.tradeValue * 2)
    }

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
