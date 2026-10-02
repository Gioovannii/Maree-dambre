import SwiftUI

struct WorldPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsExpeditions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text(L10n.text("Les rivages voisins", "Neighboring Shores")).font(.title.bold()).fontDesign(.serif)
                Text(L10n.text("Votre village, les terres alentour et les autres pavillons.", "Your village, the surrounding lands and neighboring factions."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
            }
            WorldCanvas()
            VStack(alignment: .leading, spacing: 10) {
                if session.selectedTile == .home {
                    Label(L10n.text("Port d’Ambre", "Amber Harbor"), systemImage: "house.fill").font(.title3.bold())
                    Text(L10n.text("Votre village · Force disponible : \(session.state.armyPower)", "Your village · Available power: \(session.state.armyPower)"))
                    Text(L10n.text("Sélectionnez un pavillon pour découvrir vos voisins.", "Select a faction to discover your neighbors.")).foregroundStyle(Palette.muted)
                } else if let owner = session.state.bots.first(where: { $0.territory.contains(session.selectedTile) }) {
                    Label(owner.displayName, systemImage: "flag.fill").font(.title3.bold()).foregroundStyle(WorldCanvas.factionColor(owner.id))
                    Text(L10n.text("Niveau \(owner.level) · Défense \(10 + min(10, owner.level) * 4) · \(owner.territory.count) lieux", "Level \(owner.level) · Defense \(10 + min(10, owner.level) * 4) · \(owner.territory.count) locations"))
                    Text(L10n.text("Votre force : \(session.state.armyPower) · Aller-retour : \(Int(session.state.raidDuration)) s", "Your power: \(session.state.armyPower) · Round trip: \(Int(session.state.raidDuration)) s"))
                    Button(L10n.text("Voir les expéditions", "View expeditions"), systemImage: "sailboat.fill") { showsExpeditions = true }
                        .buttonStyle(.borderedProminent)
                } else {
                    Label(session.world.terrain(at: session.selectedTile).name, systemImage: "location.fill").font(.headline)
                    Text(L10n.text("Lieu libre · Les attaques ciblent les pavillons voisins.", "Unclaimed land · Attacks target neighboring factions.")).foregroundStyle(Palette.muted)
                }
                Text("Position \(session.selectedTile.x), \(session.selectedTile.y)")
                    .font(.caption).foregroundStyle(Palette.muted)
            }
            .font(.subheadline)
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 20))
            DisclosureGroup(L10n.text("Troupes, expéditions et rapport", "Troops, expeditions and report"), isExpanded: $showsExpeditions) {
                ArmyPanel().padding(.top, 12)
            }
            Text(L10n.text("Pavillons simulés hors ligne · Le tracé doré relie votre village au lieu sélectionné ; il ne représente pas une expédition en cours.", "Offline simulated factions · The golden line connects your village to the selected location; it does not represent an active expedition."))
                .font(.caption).foregroundStyle(Palette.muted)
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
