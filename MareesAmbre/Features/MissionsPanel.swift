import SwiftUI

struct MissionsPanel: View {
    @Environment(VillageSession.self) private var session
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(String(localized: "screen.missions.subtitle", defaultValue: "Préparez vos expéditions et suivez le retour de vos troupes."))
                .font(.subheadline).foregroundStyle(Palette.muted)
            BeginnerProtectionPanel()
            if session.state.nextBotAttackAt != nil { CoastalDefensePanel() }
            HeroPanel()
            FoundingMissionStatus()
            ShipmentPanel()
            WorldClockStatus()
            ArmyPanel()
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
