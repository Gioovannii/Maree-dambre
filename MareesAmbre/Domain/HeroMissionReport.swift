import Foundation

struct HeroMissionReport: Codable, Equatable {
    let mission: HeroMissionKind
    let experience: Int
    let materials: Int
    var boatUnlocked: Bool { mission == .repairBoat }
    var isValid: Bool {
        (0...mission.experience).contains(experience) && (0...mission.materials).contains(materials)
    }
}
