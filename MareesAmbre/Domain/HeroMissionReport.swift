import Foundation

struct HeroMissionReport: Codable, Equatable {
    let mission: HeroMissionKind
    let experience: Int
    let materials: Int
    var equipment: HeroEquipment?
    var boatUnlocked: Bool { mission == .repairBoat }
    var isValid: Bool {
        (equipment?.isValid ?? true)
            && (mission.chapter == nil || (equipment ?? HeroEquipment()).highestLevel == 0)
            && (0...(equipment ?? HeroEquipment()).experience(for: mission)).contains(experience)
            && (0...(equipment ?? HeroEquipment()).materials(for: mission)).contains(materials)
    }
}
