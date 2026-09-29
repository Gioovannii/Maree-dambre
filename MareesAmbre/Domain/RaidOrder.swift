import Foundation

struct RaidOrder: Codable, Equatable {
    let targetID: Int
    let targetName: String
    let units: [ArmyUnit: Int]
    let defense: Int
    let returnsAt: Date
}
