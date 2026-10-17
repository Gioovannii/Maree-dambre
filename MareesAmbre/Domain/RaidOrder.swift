import Foundation

struct RaidOrder: Codable, Equatable {
    var targetDisplayName: String {
        targetName
    }
    var attackPower: Int {
        units.reduce(0) { $0 + ($1.key.attack + (weaponLevels?[$1.key] ?? attackUpgrade ?? 0)) * $1.value }
    }

    let targetID: Int
    let targetName: String
    let units: [ArmyUnit: Int]
    let defense: Int
    let returnsAt: Date
    var attackUpgrade: Int? = nil
    var victoryLossRate: Double? = nil
    var defeatLossRate: Double? = nil
    var transportBonusPercent: Int? = nil
    var lootLimit: Int? = nil
    var weaponLevels: [ArmyUnit: Int]? = nil
}
