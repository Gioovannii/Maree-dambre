import SwiftUI

struct WorldPanel: View {
    var onShowVillage: () -> Void = {}
    var onShowMissions: () -> Void = {}
    var mapHeight: CGFloat = 420
    var showsSelection = true

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text(String(localized: "screen.world.neighboring_shores", defaultValue: "Les rivages voisins")).font(.title2.bold()).fontDesign(.serif)
                Text(String(localized: "world.map.subtitle", defaultValue: "Explorez l’archipel et découvrez vos voisins."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
            }
            WorldCanvas(mapHeight: mapHeight)
            if showsSelection {
                WorldSelectionPanel(onShowVillage: onShowVillage, onShowMissions: onShowMissions)
            }
            Text(String(localized: "screen.world.offline_simulated_factions_the_golden_line_connects_your_village_to_the_selected_loca", defaultValue: "Pavillons simulés hors ligne · Le tracé doré relie votre village au lieu sélectionné ; il ne représente pas une expédition en cours."))
                .font(.caption).foregroundStyle(Palette.muted)
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
