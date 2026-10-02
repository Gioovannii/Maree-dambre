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
}
