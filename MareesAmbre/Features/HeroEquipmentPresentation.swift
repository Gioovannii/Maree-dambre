import Foundation

extension HeroEquipmentKind {
    func effect(at level: Int) -> String {
        switch self {
        case .spyglass:
            let bonus = (Double(level) / 10).formatted(.percent.precision(.fractionLength(0)))
            return String(localized: "hero.equipment.xp_effect", defaultValue: "+\(String(bonus)) XP sur les missions personnelles")
        case .outfit:
            return String(localized: "hero.equipment.material_effect", defaultValue: "Matériel maritime par mission : +\(String(level))")
        case .sail:
            let reduction = (Double(25 + level * 5) / 100).formatted(.percent.precision(.fractionLength(0)))
            return String(localized: "hero.equipment.speed_effect", defaultValue: "Durée initiale réduite de \(String(reduction))")
        }
    }
}
