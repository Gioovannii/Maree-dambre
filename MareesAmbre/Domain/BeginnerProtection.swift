import Foundation

struct BeginnerProtection: Codable, Equatable {
    static let initialDuration: TimeInterval = 72 * 3_600
    static let extensionDuration: TimeInterval = 48 * 3_600
    let startedAt: Date
    var extensionUsed = false
    var expiryNotified = false

    var endsAt: Date {
        startedAt.addingTimeInterval(Self.initialDuration + (extensionUsed ? Self.extensionDuration : 0))
    }
    func isActive(at now: Date) -> Bool { now < endsAt }
    func canExtend(at now: Date) -> Bool { !extensionUsed && isActive(at: now) }
    var isValid: Bool {
        startedAt >= .distantPast && startedAt <= .distantFuture
            && endsAt >= .distantPast && endsAt <= .distantFuture
    }
}
