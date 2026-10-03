import SwiftUI

struct WorldClockStatus: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.headline).foregroundStyle(Palette.amber)
                .frame(width: 38, height: 38)
                .background(Palette.amber.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(String(localized: "screen.world_clock_status.the_world_keeps_moving", defaultValue: "LE MONDE CONTINUE"))
                    .font(.caption.bold()).tracking(1.5).foregroundStyle(Palette.paper)
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    Text(String(localized: "screen.world_clock_status.next_resource_value_production_and_factions_progress_offline", defaultValue: "Prochaine ressource \(String(session.nextProductionIn(at: timeline.date))) · production et factions avancent hors ligne."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel.opacity(0.8), in: .rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}
