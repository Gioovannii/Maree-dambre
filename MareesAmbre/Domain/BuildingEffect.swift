import Foundation

extension VillageState {
    func buildingEffect(_ kind: BuildingKind, level: Int) -> String {
        let base = baseBuildingEffect(kind, level: level)
        guard let people, people.specialtyBuilding == kind else { return base }
        return base + "\n" + people.specialtyTitle + " : " + people.specialtyEffect(at: level)
    }

    private func baseBuildingEffect(_ kind: BuildingKind, level: Int) -> String {
        switch kind {
        case .hall:
            return String(localized: "progression.effect.hall", defaultValue: "+\(String(level * 2)) bois · +\(String(level)) ambre · +\(String(level * 2)) vivres / h · Durée des chantiers : \(pow(0.97, Double(level - 1)).formatted(.percent.precision(.fractionLength(0))))")
        case .lumbermill, .farm, .amberWorks:
            let amount = max(kind.yield.wood, kind.yield.amber, kind.yield.provisions) * level
            let resource = kind.requiredResourceSite?.yieldLabel ?? ""
            return String(localized: "progression.effect.production", defaultValue: "+\(String(amount)) \(String(resource)) / h")
        case .warehouse:
            return String(localized: "progression.effect.storage", defaultValue: "Capacité de réserve : \(String(300 + 500 * level)) par ressource")
        case .watchtower:
            return String(localized: "progression.effect.defense", defaultValue: "+\(String(20 * level)) de défense du port")
        case .warCourt:
            let duration = GameProgression.durationText(ceil(30 / (1 + 0.08 * Double(level - 1))))
            return String(localized: "army.capacity.training_effect", defaultValue: "Entraînement : \(String(duration)) par unité · Capacité : \(String(min(ArmyState.maximumTroops, level * 100))) troupes")
        case .academy:
            let duration = GameProgression.durationText(ceil(60 / (1 + 0.08 * Double(level - 1))))
            return String(localized: "progression.effect.academy", defaultValue: "Débloquer une unité : \(String(duration)) · Durée des recherches d’armes : \((1 / (1 + 0.04 * Double(level - 1))).formatted(.percent.precision(.fractionLength(0))))")
        case .market:
            return String(localized: "progression.effect.market", defaultValue: "Valeur conservée à l’échange : \((0.5 + 0.025 * Double(level - 1)).formatted(.percent.precision(.fractionLength(1))))")
        case .forge:
            return String(localized: "progression.effect.forge", defaultValue: "Recherche des armes jusqu’au niveau \(String(level)) par type d’unité")
        case .infirmary:
            return String(localized: "progression.effect.infirmary", defaultValue: "Pertes sans mage : \((0.1 - 0.005 * Double(level - 1)).formatted(.percent.precision(.fractionLength(1)))) en victoire · \((0.35 - 0.01 * Double(level - 1)).formatted(.percent.precision(.fractionLength(0)))) en défaite")
        case .expeditionQuay:
            return String(localized: "progression.effect.quay", defaultValue: "+\((Double(25 + 5 * (level - 1)) / 100).formatted(.percent)) de transport · butin jusqu’à \(String(90 + 20 * (level - 1))) par ressource")
        }
    }
}
