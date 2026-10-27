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
            }

            RaidReminderPanel()
            Button {
                showsDefense = true
            } label: {
                Label(String(localized: "screen.defense.organize", defaultValue: "Organiser la défense"), systemImage: "shield.fill")
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
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
