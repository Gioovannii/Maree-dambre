import SwiftUI

struct WorldPanel: View {
    @Environment(VillageSession.self) private var session
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("La mer des Échos").font(.title.bold()).fontDesign(.serif)
            Text("Suivez les courants. Retrouvez les autres rivages.").font(.subheadline).foregroundStyle(Palette.muted)
            WorldCanvas()
            VStack(alignment: .leading, spacing: 8) {
                Text("Case \(session.selectedTile.x), \(session.selectedTile.y)").font(.headline)
                Text(session.world.terrain(at: session.selectedTile).name)
                if session.selectedTile == .home {
                    Label("Port d’Ambre · Votre village", systemImage: "star.fill").foregroundStyle(Palette.amber)
                } else if let owner = session.state.bots.first(where: { $0.territory.contains(session.selectedTile) }) {
                    Text("Territoire de \(owner.name) · Niveau \(owner.level)")
                } else {
                    Text("Zone libre. Déplacements d’unités et conquête à venir.").foregroundStyle(Palette.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(Palette.ocean, in: .rect(cornerRadius: 16))
            Text("Les autres pavillons").font(.headline)
            ForEach(session.state.bots) { bot in
                Button { session.selectedTile = bot.capital } label: {
                    HStack(alignment: .top) {
                        Text("\(bot.id + 1)").bold().padding(10).background(WorldCanvas.factionColor(bot.id), in: .circle).foregroundStyle(Palette.ocean)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bot.name).bold()
                            Text("Niveau \(bot.level) · \(bot.territory.count) cases").font(.subheadline)
                            Text("Voir la capitale (\(bot.capital.x), \(bot.capital.y))").font(.footnote)
                        }
                        Spacer()
                        Image(systemName: "scope")
                    }
                    .padding(10)
                }
                .buttonStyle(.plain).foregroundStyle(Palette.paper)
            }
            Text("Les autres peuples étendent leur territoire toutes les six heures, jusqu’à 64 lieux chacun. Votre village reste protégé. Les expéditions et les combats arriveront plus tard.")
                .font(.footnote).foregroundStyle(Palette.muted)
        }
        .padding(.vertical, 12)
    }
}
