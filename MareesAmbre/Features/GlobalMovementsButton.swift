import SwiftUI

struct GlobalMovementsButton: View {
    @Environment(VillageSession.self) private var session
    @State private var showsMovements = false

    var body: some View {
        Button { showsMovements = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.arrow.down")
                Text(String(localized: "movements.title", defaultValue: "Mouvements"))
                Text(session.state.worldExpeditions.count, format: .number)
                    .monospacedDigit().bold()
                Spacer()
                if let next = session.state.nextDomainBotAttackDate {
                    Image(systemName: "shield.lefthalf.filled")
                    Text(next, style: .relative).monospacedDigit()
                }
                Image(systemName: "chevron.up")
            }
            .font(.caption).foregroundStyle(Palette.paper)
            .padding(.horizontal, 14).frame(minHeight: 44)
            .background(Palette.panel, in: .capsule)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showsMovements) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let next = session.state.nextDomainBotAttackDate {
                            Label(String(localized: "movements.incoming", defaultValue: "Prochain assaut prévu"), systemImage: "shield.lefthalf.filled")
                                .foregroundStyle(Palette.amber)
                            Text(next, style: .date)
                            Text(next, style: .time)
                        }
                        WorldExpeditionsPanel(initiallyExpanded: true)
                    }
                    .padding()
                }
                .background(Palette.ocean).foregroundStyle(Palette.paper)
                .navigationTitle(String(localized: "movements.title", defaultValue: "Mouvements"))
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "screen.raid.close", defaultValue: "Fermer")) { showsMovements = false }
                    }
                }
            }
            .tint(Palette.amber)
        }
    }
}
