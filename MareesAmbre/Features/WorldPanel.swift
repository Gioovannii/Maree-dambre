import SwiftUI

struct WorldPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsExpeditions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Les rivages voisins").font(.title.bold()).fontDesign(.serif)
                Text("Votre village, les terres alentour et les autres pavillons.")
                    .font(.subheadline).foregroundStyle(Palette.muted)
            }
            WorldCanvas()
            VStack(alignment: .leading, spacing: 10) {
                if session.selectedTile == .home {
                    Label("Port d’Ambre", systemImage: "house.fill").font(.title3.bold())
                    Text("Votre village · Force disponible : \(session.state.armyPower)")
                    Text("Sélectionnez un pavillon pour découvrir vos voisins.").foregroundStyle(Palette.muted)
                } else if let owner = session.state.bots.first(where: { $0.territory.contains(session.selectedTile) }) {
                    Label(owner.name, systemImage: "flag.fill").font(.title3.bold()).foregroundStyle(WorldCanvas.factionColor(owner.id))
                    Text("Niveau \(owner.level) · Défense \(10 + min(10, owner.level) * 4) · \(owner.territory.count) lieux")
                    Text("Votre force : \(session.state.armyPower) · Aller-retour : \(Int(session.state.raidDuration)) s")
                    Button("Voir les expéditions", systemImage: "sailboat.fill") { showsExpeditions = true }
                        .buttonStyle(.borderedProminent)
                } else {
                    Label(session.world.terrain(at: session.selectedTile).name, systemImage: "location.fill").font(.headline)
                    Text("Lieu libre · Les attaques ciblent les pavillons voisins.").foregroundStyle(Palette.muted)
                }
                Text("Position \(session.selectedTile.x), \(session.selectedTile.y)")
                    .font(.caption).foregroundStyle(Palette.muted)
            }
            .font(.subheadline)
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 20))
            DisclosureGroup("Troupes, expéditions et rapport", isExpanded: $showsExpeditions) {
                ArmyPanel().padding(.top, 12)
            }
            Text("Pavillons simulés hors ligne · Le tracé doré relie votre village au lieu sélectionné ; il ne représente pas une expédition en cours.")
                .font(.caption).foregroundStyle(Palette.muted)
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
