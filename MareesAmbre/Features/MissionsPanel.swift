import SwiftUI

struct MissionsPanel: View {
    @Environment(VillageSession.self) private var session
    var onOpenDomainObjective: (DomainObjective) -> Void = { _ in }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(String(localized: "screen.missions.subtitle", defaultValue: "Préparez vos expéditions et suivez le retour de vos troupes."))
                .font(.subheadline).foregroundStyle(Palette.muted)
            if let objective = session.state.nextDomainObjective, objective.kind != .established {
                DomainObjectiveCard(objective: objective, onContinue: onOpenDomainObjective)
            }
            LighthousePanel()
            HeroPanel()
            PeopleSpecialtyPanel()
            BeginnerProtectionPanel()
            if session.state.nextDomainBotAttackDate != nil { CoastalDefensePanel() }
            FoundingMissionStatus()
            ShipmentPanel()
            WorldClockStatus()
            ArmyPanel()
        }
        .tint(Palette.amber)
        .padding(.vertical, 12)
    }
}
