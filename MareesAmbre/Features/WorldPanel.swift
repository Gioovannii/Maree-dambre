import SwiftUI

struct WorldPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsExpeditions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text(String(localized: "screen.world.neighboring_shores", defaultValue: "Les rivages voisins")).font(.title.bold()).fontDesign(.serif)
                Text(String(localized: "screen.world.your_village_the_surrounding_lands_and_neighboring_factions", defaultValue: "Votre village, les terres alentour et les autres pavillons."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
            }
            WorldCanvas()
            VStack(alignment: .leading, spacing: 10) {
                if session.selectedTile == .home {
                    Label(String(localized: "screen.world.amber_harbor", defaultValue: "Port d’Ambre"), systemImage: "house.fill").font(.title3.bold())
                    Text(String(localized: "screen.world.your_village_available_power_value", defaultValue: "Votre village · Force disponible : \(String(session.state.armyPower))"))
                    Text(String(localized: "screen.world.select_a_faction_to_discover_your_neighbors", defaultValue: "Sélectionnez un pavillon pour découvrir vos voisins.")).foregroundStyle(Palette.muted)
                } else if let owner = session.state.bots.first(where: { $0.territory.contains(session.selectedTile) }) {
                    Label(owner.displayName, systemImage: "flag.fill").font(.title3.bold()).foregroundStyle(WorldCanvas.factionColor(owner.id))
                    Text(String(localized: "screen.world.level_value_defense_value_value_locations", defaultValue: "Niveau \(String(owner.level)) · Défense \(String(10 + min(10, owner.level) * 4)) · \(String(owner.territory.count)) lieux"))
                    Text(String(localized: "screen.world.your_power_value_round_trip_value_s", defaultValue: "Votre force : \(String(session.state.armyPower)) · Aller-retour : \(String(Int(session.state.raidDuration))) s"))
                    Button(String(localized: "screen.world.view_expeditions", defaultValue: "Voir les expéditions"), systemImage: "sailboat.fill") { showsExpeditions = true }
                        .buttonStyle(.borderedProminent)
                } else {
                    Label(session.world.terrain(at: session.selectedTile).name, systemImage: "location.fill").font(.headline)
                    Text(String(localized: "screen.world.unclaimed_land_attacks_target_neighboring_factions", defaultValue: "Lieu libre · Les attaques ciblent les pavillons voisins.")).foregroundStyle(Palette.muted)
                }
                Text(String(localized: "screen.world_panel.position", defaultValue: "Position \(String(session.selectedTile.x)), \(String(session.selectedTile.y))"))
                    .font(.caption).foregroundStyle(Palette.muted)
            }
            .font(.subheadline)
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 20))
            DisclosureGroup(String(localized: "screen.world.troops_expeditions_and_report", defaultValue: "Troupes, expéditions et rapport"), isExpanded: $showsExpeditions) {
                ArmyPanel().padding(.top, 12)
            }
            Text(String(localized: "screen.world.offline_simulated_factions_the_golden_line_connects_your_village_to_the_selected_loca", defaultValue: "Pavillons simulés hors ligne · Le tracé doré relie votre village au lieu sélectionné ; il ne représente pas une expédition en cours."))
                .font(.caption).foregroundStyle(Palette.muted)
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
