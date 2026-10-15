import SwiftUI

struct CoastalDefensePanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsDefense = ProcessInfo.processInfo.arguments.contains("--snapshot-defense")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(String(localized: "screen.defense.title", defaultValue: "Défense du port"), systemImage: "shield.lefthalf.filled")
                .font(.headline)
            Text(String(localized: "screen.defense.power", defaultValue: "Défense disponible : \(String(session.state.garrisonDefense))"))
            if let campaign = session.state.coastalCampaign {
                Text(String(localized: "screen.defense.incoming", defaultValue: "Assaut dans \(String(campaign.tidesUntilAssault)) marée(s) · Force ennemie : \(String(campaign.enemyPower))"))
                    .accessibilityIdentifier("defense.incoming")
            } else {
                Text(String(localized: "screen.defense.intro", defaultValue: "Ouvrez la campagne côtière quand votre garnison est prête. Les corsaires progressent avec vos décisions."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
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
