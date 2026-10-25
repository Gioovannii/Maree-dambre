import SwiftUI

/// A compact view of active raids that leaves the estate itself unobstructed.
struct ActiveRaidsStrip: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        let raids = session.state.worldExpeditions.filter(\.isRaid)
        if !raids.isEmpty || session.state.nextDomainBotAttackDate != nil {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        if let next = session.state.nextDomainBotAttackDate {
                            HStack(spacing: 8) {
                                Image(systemName: "shield.lefthalf.filled").foregroundStyle(Palette.amber)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "movements.incoming", defaultValue: "Prochain assaut prévu"))
                                    if let target = session.state.nextBotRaidTargetName {
                                        Text(String(localized: "movements.target", defaultValue: "Cible : \(target)"))
                                            .font(.caption2).foregroundStyle(Palette.muted)
                                    }
                                }
                                Text(GameProgression.durationText(max(0, next.timeIntervalSince(timeline.date))))
                                    .monospacedDigit().bold()
                            }
                            .font(.caption).foregroundStyle(Palette.paper)
                            .padding(10)
                            .background(Palette.ocean.opacity(0.92), in: .rect(cornerRadius: 14))
                        }
                        ForEach(raids) { raid in
                            HStack(spacing: 8) {
                                Image(systemName: raid.isReturning(at: timeline.date) ? "arrow.uturn.backward" : "flag.fill")
                                    .foregroundStyle(Palette.amber)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(raid.title).font(.caption.bold()).lineLimit(1)
                                    Text(raid.isReturning(at: timeline.date)
                                         ? String(localized: "world.travel.return", defaultValue: "Retour vers le village")
                                         : String(localized: "world.travel.attack", defaultValue: "Raid en route vers la cible"))
                                        .font(.caption).foregroundStyle(Palette.muted)
                                }
                                Text(GameProgression.durationText(max(0, raid.endsAt.timeIntervalSince(timeline.date))))
                                    .font(.caption.bold()).monospacedDigit()
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .foregroundStyle(Palette.paper)
                            .background(Palette.ocean.opacity(0.92), in: .rect(cornerRadius: 14))
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
