import Foundation

struct HeroEquipment: Codable, Equatable {
    var spyglass = 0
    var outfit = 0
    var sail = 0
    subscript(kind: HeroEquipmentKind) -> Int {
        get { switch kind { case .spyglass: spyglass; case .outfit: outfit; case .sail: sail } }
        set { switch kind { case .spyglass: spyglass = newValue; case .outfit: outfit = newValue; case .sail: sail = newValue } }
    }
    var highestLevel: Int { max(spyglass, outfit, sail) }
    var isValid: Bool { [spyglass, outfit, sail].allSatisfy { (0...HeroEquipmentKind.maximumLevel).contains($0) } }
    /// Additive with the boat's 25 percent reduction, capped at 40 percent total.
    var durationMultiplier: Double { Double(75 - sail * 5) / 100 }
    func experience(for mission: HeroMissionKind) -> Int {
        mission.chapter == nil ? mission.experience * (100 + spyglass * 10) / 100 : mission.experience
    }
    func materials(for mission: HeroMissionKind) -> Int {
        mission.materials + (mission.chapter == nil ? outfit : 0)
    }
}

extension VillageState {
    func canUpgradeHeroEquipment(_ kind: HeroEquipmentKind) -> Bool {
        guard let hero, let missions = hero.missions, missions.hasBoat, missions.voyage == nil else { return false }
        let next = (missions.equipment ?? HeroEquipment())[kind] + 1
        return (1...HeroEquipmentKind.maximumLevel).contains(next)
            && hero.level >= HeroEquipmentKind.requiredHeroLevel(for: next)
            && missions.materials >= kind.materialCost(for: next)
    }
    @discardableResult
    mutating func upgradeHeroEquipment(_ kind: HeroEquipmentKind) -> Bool {
        guard canUpgradeHeroEquipment(kind), var captain = hero, var missions = captain.missions else { return false }
        var equipment = missions.equipment ?? HeroEquipment()
        let next = equipment[kind] + 1
        missions.materials -= kind.materialCost(for: next)
        equipment[kind] = next
        missions.equipment = equipment
        captain.missions = missions
        hero = captain
        return true
    }
}
