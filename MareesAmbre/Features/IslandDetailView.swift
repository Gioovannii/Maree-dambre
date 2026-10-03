import SwiftUI

struct IslandDetailView: View {
    @Environment(GameSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label(session.selected.isHome ? String(localized: "screen.island_detail.your_harbor", defaultValue: "VOTRE ESCALE") : String(localized: "screen.island_detail.unexplored_horizon", defaultValue: "HORIZON À EXPLORER"), systemImage: session.selected.isHome ? "flag.fill" : "binoculars.fill")
                .font(.caption.bold()).foregroundStyle(Palette.amber)
            Text(session.selected.name).font(.largeTitle.bold()).fontDesign(.serif)
            Text(session.selected.subtitle).foregroundStyle(Palette.muted)
            Divider().overlay(Palette.muted.opacity(0.3))
            if session.selected.isHome {
                LabeledContent(String(localized: "screen.island_detail.harbor", defaultValue: "Port"), value: String(localized: "screen.island_detail.level_value_4", defaultValue: "Niveau \(String(session.selected.portLevel)) / 4"))
                Text(String(localized: "screen.island_detail.expand_your_harbor_to_prepare_for_future_expeditions", defaultValue: "Agrandissez votre port pour préparer les prochaines expéditions."))
                    .foregroundStyle(Palette.muted)
                if let cost = session.game.developmentCost(for: session.selectedID) {
                    Text(String(localized: "screen.island_detail.cost_value_wood_value_amber", defaultValue: "Coût : \(String(cost.wood)) bois · \(String(cost.amber)) ambre")).font(.subheadline)
                    Button(String(localized: "screen.island_detail.expand_harbor", defaultValue: "Développer le port"), systemImage: "hammer.fill", action: session.develop)
                        .buttonStyle(.borderedProminent).tint(Palette.amber).foregroundStyle(Palette.ocean)
                        .controlSize(.large).disabled(!session.game.canDevelop(session.selectedID))
                    if !session.game.canDevelop(session.selectedID) {
                        Text(String(localized: "screen.island_detail.not_enough_resources_harvesting_will_be_added_in_a_future_version", defaultValue: "Ressources insuffisantes. La récolte sera ajoutée dans une prochaine version.")).font(.subheadline)
                    }
                } else {
                    Label(String(localized: "screen.island_detail.harbor_at_prototype_maximum", defaultValue: "Port au maximum du prototype"), systemImage: "checkmark.seal.fill")
                }
            } else {
                Text(String(localized: "screen.island_detail.unclaimed_land_beyond_your_harbor_map_expeditions_will_be_added_in_a_future_version", defaultValue: "Une terre encore libre, au-delà de votre port. Les expéditions sur la carte seront ajoutées dans une prochaine version."))
                    .foregroundStyle(Palette.muted)
            }
            Text(session.message).font(.footnote).foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(24)
        .background(Palette.panel, in: .rect(cornerRadius: 28))
    }
}
