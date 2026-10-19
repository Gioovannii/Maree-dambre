import Foundation

struct FoundingVoyage: Codable, Equatable {
    let destination: TileCoordinate
    let role: SettlementRole
    let isRefuge: Bool
    let escort: ArmyUnit
    let arrivesAt: Date
    static let escortCount = 5

    var isValid: Bool {
        destination.isValid && destination != .home
            && arrivesAt >= .distantPast && arrivesAt <= .distantFuture
    }
}
