import SwiftUI

struct MissionsPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(String(localized: "screen.missions.subtitle", defaultValue: "Préparez vos expéditions et suivez le retour de vos troupes."))
                .font(.subheadline).foregroundStyle(Palette.muted)
            WorldClockStatus()
            ArmyPanel()
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
