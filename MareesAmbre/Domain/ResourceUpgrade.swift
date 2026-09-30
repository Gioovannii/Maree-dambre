import Foundation

struct ResourceUpgrade: Codable, Equatable, Sendable {
    let plot: Int
    let targetLevel: Int
    let startedAt: Date
    let cost: Resources

    var endsAt: Date { startedAt.addingTimeInterval(60) }
    func progress(at date: Date) -> Double {
        min(1, max(0, date.timeIntervalSince(startedAt) / 60))
    }
}
