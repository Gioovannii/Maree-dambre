import Foundation

struct ConstructionJob: Codable, Equatable, Sendable {
    let plot: Int
    let kind: BuildingKind
    let startedAt: Date
    let duration: TimeInterval
    var targetLevel: Int? = nil
    var paidCost: Resources? = nil

    var level: Int { targetLevel ?? 1 }
    var cost: Resources { paidCost ?? kind.cost }

    var endsAt: Date { startedAt.addingTimeInterval(duration) }

    func progress(at date: Date) -> Double {
        min(1, max(0, date.timeIntervalSince(startedAt) / duration))
    }
}
