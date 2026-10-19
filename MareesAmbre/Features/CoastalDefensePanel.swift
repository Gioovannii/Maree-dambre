import SwiftUI

struct CoastalDefensePanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsDefense = ProcessInfo.processInfo.arguments.contains("--snapshot-defense")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(String(localized: "screen.defense.title", defaultValue: "Défense du port"), systemImage: "shield.lefthalf.filled")
                .font(.headline)
            Text(String(localized: "screen.defense.power", defaultValue: "Défense disponible : \(String(session.state.garrisonDefense))"))
            ScheduledBotAttackPanel()
            if session.state.isUnderProtection() {
                Label(String(localized: "protection.assaults_paused", defaultValue: "Assauts suspendus pendant votre protection"), systemImage: "shield.fill")
                    .font(.subheadline).foregroundStyle(Palette.amber)
            } else if let campaign = session.state.coastalCampaign {
                if let attackerID = campaign.attackerID,
                   let attacker = session.state.bots.first(where: { $0.id == attackerID }) {
                    Text(String(localized: "screen.defense.attacker", defaultValue: "Assaillant : \(String(WorldNeighbor.name(for: attacker, seed: session.world.seed))) · \(String(attacker.displayName))"))
                        .font(.subheadline.bold())
                }
                Text(String(localized: "screen.defense.incoming", defaultValue: "Assaut dans \(String(campaign.tidesUntilAssault)) marée(s) · Force ennemie : \(String(campaign.enemyPower))"))
                    .accessibilityIdentifier("defense.incoming")
            } else if session.state.nextBotAttackAt == nil {
                Text(String(localized: "screen.defense.intro", defaultValue: "Ouvrez la campagne quand votre garnison est prête. Les tribus voisines attaquent à tour de rôle."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            RaidReminderPanel()
            Button {
                showsDefense = true
            } label: {
                AdaptiveActionLabel(title: String(localized: "screen.defense.organize", defaultValue: "Organiser la défense"), systemImage: "shield.fill")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .accessibilityIdentifier("defense.open")
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 20))
        .sheet(isPresented: $showsDefense) { CoastalDefenseView() }
    }
}
