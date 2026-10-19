import Foundation

struct HeroVoyage: Codable, Equatable {
    let mission: HeroMissionKind
    let origin: TileCoordinate
    let startedAt: Date
    let duration: TimeInterval
    var equipment: HeroEquipment?
    var endsAt: Date { startedAt.addingTimeInterval(duration) }
    var isValid: Bool {
        (equipment?.isValid ?? true)
            && (mission.chapter == nil || (equipment ?? HeroEquipment()).highestLevel == 0)
            && origin.isValid && startedAt >= .distantPast && endsAt <= .distantFuture
            && (mission.chapter != nil
                ? duration == mission.baseDuration
                : duration == mission.baseDuration * (equipment ?? HeroEquipment()).durationMultiplier)
    }
}
