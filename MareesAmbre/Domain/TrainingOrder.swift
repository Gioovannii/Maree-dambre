import Foundation

struct TrainingOrder: Codable, Equatable {
    let unit: ArmyUnit
    let count: Int
    let endsAt: Date
}
