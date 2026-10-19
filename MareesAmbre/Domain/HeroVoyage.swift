import Foundation

struct HeroVoyage: Codable, Equatable {
    let mission: HeroMissionKind
    let origin: TileCoordinate
    let startedAt: Date
    let duration: TimeInterval
    var endsAt: Date { startedAt.addingTimeInterval(duration) }
    var isValid: Bool {
        origin.isValid && startedAt >= .distantPast && endsAt <= .distantFuture
            && (duration == mission.baseDuration || (mission.chapter == nil && duration == mission.baseDuration * 0.75))
    }
}
