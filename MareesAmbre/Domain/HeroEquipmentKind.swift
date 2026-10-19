import Foundation

enum HeroEquipmentKind: String, CaseIterable, Codable, Identifiable {
    case spyglass, outfit, sail
    var id: Self { self }
    static let maximumLevel = 3
    func materialCost(for level: Int) -> Int {
        guard (1...Self.maximumLevel).contains(level) else { return 0 }
        switch self {
        case .spyglass: return [4, 9, 16][level - 1]
        case .outfit: return [5, 11, 18][level - 1]
        case .sail: return [6, 13, 22][level - 1]
        }
    }
    static func requiredHeroLevel(for equipmentLevel: Int) -> Int { equipmentLevel * 2 }
    var title: String {
        switch self {
        case .spyglass: String(localized: "hero.equipment.spyglass", defaultValue: "Longue-vue")
        case .outfit: String(localized: "hero.equipment.outfit", defaultValue: "Tenue de marin")
        case .sail: String(localized: "hero.equipment.sail", defaultValue: "Voile renforcée")
        }
    }
    var symbol: String {
        switch self { case .spyglass: "binoculars.fill"; case .outfit: "tshirt.fill"; case .sail: "sailboat.fill" }
    }
}
