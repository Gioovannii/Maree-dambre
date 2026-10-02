import SwiftUI

struct IslandDetailView: View {
    @Environment(GameSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label(session.selected.isHome ? L10n.text("VOTRE ESCALE", "YOUR HARBOR") : L10n.text("HORIZON À EXPLORER", "UNEXPLORED HORIZON"), systemImage: session.selected.isHome ? "flag.fill" : "binoculars.fill")
                .font(.caption.bold()).foregroundStyle(Palette.amber)
            Text(session.selected.name).font(.largeTitle.bold()).fontDesign(.serif)
            Text(session.selected.subtitle).foregroundStyle(Palette.muted)
            Divider().overlay(Palette.muted.opacity(0.3))
            if session.selected.isHome {
                LabeledContent("Port", value: L10n.text("Niveau \(session.selected.portLevel) / 4", "Level \(session.selected.portLevel) / 4"))
                Text(L10n.text("Agrandissez votre port pour préparer les prochaines expéditions.", "Expand your harbor to prepare for future expeditions."))
                    .foregroundStyle(Palette.muted)
                if let cost = session.game.developmentCost(for: session.selectedID) {
                    Text(L10n.text("Coût : \(cost.wood) bois · \(cost.amber) ambre", "Cost: \(cost.wood) wood · \(cost.amber) amber")).font(.subheadline)
                    Button(L10n.text("Développer le port", "Expand harbor"), systemImage: "hammer.fill", action: session.develop)
                        .buttonStyle(.borderedProminent).tint(Palette.amber).foregroundStyle(Palette.ocean)
                        .controlSize(.large).disabled(!session.game.canDevelop(session.selectedID))
                    if !session.game.canDevelop(session.selectedID) {
                        Text(L10n.text("Ressources insuffisantes. La récolte sera ajoutée dans une prochaine version.", "Not enough resources. Harvesting will be added in a future version.")).font(.subheadline)
                    }
                } else {
                    Label(L10n.text("Port au maximum du prototype", "Harbor at prototype maximum"), systemImage: "checkmark.seal.fill")
                }
            } else {
                Text(L10n.text("Une terre encore libre, au-delà de votre port. Les expéditions sur la carte seront ajoutées dans une prochaine version.", "Unclaimed land beyond your harbor. Map expeditions will be added in a future version."))
                    .foregroundStyle(Palette.muted)
            }
            Text(session.message).font(.footnote).foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(24)
        .background(Palette.panel, in: .rect(cornerRadius: 28))
    }
}
