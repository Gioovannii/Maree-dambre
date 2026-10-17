import Foundation

struct ResourceUpgrade: Codable, Equatable, Sendable {
    let plot: Int
    let targetLevel: Int
    let startedAt: Date
    let cost: Resources
    var duration: TimeInterval? = nil

    var effectiveDuration: TimeInterval { duration ?? 60 }
    var endsAt: Date { startedAt.addingTimeInterval(effectiveDuration) }
    func progress(at date: Date) -> Double {
        min(1, max(0, date.timeIntervalSince(startedAt) / effectiveDuration))
    }
}
