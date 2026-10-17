import Foundation

struct RaidOrder: Codable, Equatable {
    var targetDisplayName: String {
        BotFaction.starting.first(where: { $0.id == targetID })?.displayName ?? targetName
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
