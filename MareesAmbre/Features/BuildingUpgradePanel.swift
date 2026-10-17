import SwiftUI

struct BuildingUpgradePanel: View {
    let kind: BuildingKind
    let plot: Int
    @Environment(VillageSession.self) private var session

    var body: some View {
        let level = session.state.buildingLevel(kind)
        VStack(alignment: .leading, spacing: 10) {
            Label(String(localized: "progression.building.level", defaultValue: "Niveau \(String(level)) / \(String(GameProgression.maximumBuildingLevel))"), systemImage: "arrow.up.circle.fill")
                .font(.headline)
            if level < GameProgression.maximumBuildingLevel {
                let target = level + 1
                let cost = kind.cost(for: target)
                Text(String(localized: "progression.building.next", defaultValue: "Au niveau \(String(target)) : \(String(session.state.buildingEffect(kind, level: target)))"))
                    .font(.subheadline).foregroundStyle(Palette.amber)
                Text(String(localized: "screen.construction.cost_value_wood_value_amber_value_food", defaultValue: "Coût : \(String(cost.wood)) bois · \(String(cost.amber)) ambre · \(String(cost.provisions)) vivres"))
                    .font(.subheadline)
                Text(String(localized: "progression.duration", defaultValue: "Durée : \(String(GameProgression.durationText(session.state.constructionDuration(for: target))))"))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                Button(String(localized: "progression.building.upgrade", defaultValue: "Améliorer au niveau \(String(target))"), systemImage: "arrow.up.circle.fill", action: session.upgradeSelectedBuilding)
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(Palette.ocean)
                    .disabled(!session.state.canUpgradeBuilding(at: plot))
                    .accessibilityIdentifier("building.upgrade")
                if session.state.construction != nil || session.state.resourceUpgrade != nil {
                    Text(String(localized: "screen.resource_site.finish_or_cancel_the_current_construction_before_starting_this_upgrade", defaultValue: "Terminez ou annulez le chantier en cours avant de commencer cette amélioration."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if !session.state.canUpgradeBuilding(at: plot) {
                    Text(session.state.meetsProductionRequirement(kind)
                         ? String(localized: "screen.construction.not_enough_resources", defaultValue: "Ressources insuffisantes")
                         : String(localized: "screen.construction.upgrade_the_matching_resource_site_to_activate_production", defaultValue: "Améliorez le terrain correspondant pour activer cette production."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                if max(cost.wood, cost.amber, cost.provisions) > session.state.storageCapacity {
                    Text(String(localized: "progression.storage_required", defaultValue: "Améliorez l’Entrepôt pour pouvoir stocker les ressources nécessaires."))
                        .font(.footnote).foregroundStyle(Palette.amber)
                }
            } else {
                Label(String(localized: "progression.building.maximum", defaultValue: "Bâtiment au niveau maximal"), systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Palette.amber)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.ocean, in: .rect(cornerRadius: 18))
    }
}
