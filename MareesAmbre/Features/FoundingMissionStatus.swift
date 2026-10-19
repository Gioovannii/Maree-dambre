import SwiftUI

struct FoundingMissionStatus: View {
    @Environment(VillageSession.self) private var session
    @State private var showsExpansion = false
    private var voyage: FoundingVoyage? {
        ([session.state] + (session.state.otherVillages ?? [])).compactMap { $0.expansion?.voyage }.first
    }
    var body: some View {
        if let voyage {
            VStack(alignment: .leading, spacing: 10) {
                Label(String(localized: "expansion.at_sea", defaultValue: "Expédition en mer"), systemImage: "sailboat.fill")
                    .font(.headline).foregroundStyle(Palette.amber)
                Text(voyage.role.name + " · \(voyage.destination.x), \(voyage.destination.y)")
                Text(voyage.arrivesAt, style: .timer).monospacedDigit()
                Button(String(localized: "expansion.navigation", defaultValue: "Colonisation")) { showsExpansion = true }
                    .buttonStyle(.bordered)
            }
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 18))
            .sheet(isPresented: $showsExpansion) { ExpansionView() }
        }
    }
}
