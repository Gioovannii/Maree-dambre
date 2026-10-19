import SwiftUI

struct ScheduledBotAttackPanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        if session.state.isRefuge {
            Label(String(localized: "bots.refuge", defaultValue: "Refuge : aucun assaut régulier"), systemImage: "shield.fill")
                .foregroundStyle(Palette.amber)
        } else if let date = session.state.scheduledBotAttackDate {
            VStack(alignment: .leading, spacing: 8) {
                Label(String(localized: "bots.next", defaultValue: "Prochain assaut régulier"), systemImage: "clock.badge.exclamationmark")
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                if ProcessInfo.processInfo.arguments.contains("--ui-snapshot"), let now = session.state.lastProductionAt {
                    Text(GameProgression.durationText(max(0, date.timeIntervalSince(now)))).monospacedDigit()
                } else {
                    Text(date, style: .relative).monospacedDigit()
                        .accessibilityIdentifier("defense.scheduledCountdown")
                }
                Text(date, format: .dateTime.day().month().hour().minute())
                    .font(.caption).foregroundStyle(Palette.muted)
                Text(String(localized: "bots.rules_rest", defaultValue: "Au plus un raid automatique par 24 h et par village, après votre protection. Aucune accumulation pendant votre absence. La garnison défend automatiquement ; les rapports attendent dans Messages."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
    }
}
