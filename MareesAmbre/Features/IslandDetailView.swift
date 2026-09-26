import SwiftUI

struct IslandDetailView: View {
    @Environment(GameSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label(session.selected.isHome ? "VOTRE ESCALE" : "HORIZON À EXPLORER", systemImage: session.selected.isHome ? "flag.fill" : "binoculars.fill")
                .font(.caption.bold()).foregroundStyle(Palette.amber)
            Text(session.selected.name).font(.largeTitle.bold()).fontDesign(.serif)
            Text(session.selected.subtitle).foregroundStyle(Palette.muted)
            Divider().overlay(Palette.muted.opacity(0.3))
            if session.selected.isHome {
                LabeledContent("Port", value: "Niveau \(session.selected.portLevel) / 4")
                Text("Agrandissez votre port pour préparer les prochaines expéditions.")
                    .foregroundStyle(Palette.muted)
                if let cost = session.game.developmentCost(for: session.selectedID) {
                    Text("Coût : \(cost.wood) bois · \(cost.amber) ambre").font(.subheadline)
                    Button("Développer le port", systemImage: "hammer.fill", action: session.develop)
                        .buttonStyle(.borderedProminent).tint(Palette.amber).foregroundStyle(Palette.ocean)
                        .controlSize(.large).disabled(!session.game.canDevelop(session.selectedID))
                    if !session.game.canDevelop(session.selectedID) {
                        Text("Ressources insuffisantes. La récolte sera ajoutée dans une prochaine version.").font(.subheadline)
                    }
                } else {
                    Label("Port au maximum du prototype", systemImage: "checkmark.seal.fill")
                }
            } else {
                Text("Une terre encore libre, au-delà de votre port. L’exploration et la conquête ne sont pas encore jouables dans ce prototype.")
                    .foregroundStyle(Palette.muted)
            }
            Text(session.message).font(.footnote).foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(24)
        .background(Palette.panel, in: .rect(cornerRadius: 28))
    }
}
