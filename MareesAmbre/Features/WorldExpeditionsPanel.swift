import SwiftUI

struct WorldExpeditionsPanel: View {
    @Environment(VillageSession.self) private var session

    @State private var expanded = false

    var body: some View {
        if !session.state.worldExpeditions.isEmpty {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                DisclosureGroup(isExpanded: $expanded) {
                    VStack(spacing: 8) {
                        ForEach(session.state.worldExpeditions) { voyage in
                            let frozen = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
                                && !ProcessInfo.processInfo.arguments.contains("--snapshot-animate")
                            let now = frozen ? voyage.startedAt.addingTimeInterval(voyage.endsAt.timeIntervalSince(voyage.startedAt) * 0.25) : timeline.date
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Label(voyage.title, systemImage: voyage.isRaid ? "flag.fill" : "sailboat.fill")
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(GameProgression.durationText(max(0, voyage.endsAt.timeIntervalSince(now))))
                                        .font(.caption).monospacedDigit()
                                }
                                Text(voyage.isReturning(at: now)
                                     ? String(localized: "world.travel.return", defaultValue: "Retour vers le village")
                                     : voyage.isRaid ? String(localized: "world.travel.attack", defaultValue: "Raid en route vers la cible")
                                     : String(localized: "world.travel.hero", defaultValue: "Héros en route vers sa mission"))
                                    .font(.caption)
                                if voyage.includesHero && voyage.isRaid {
                                    Text(String(localized: "hero.raid.onboard", defaultValue: "Héros à bord"))
                                        .font(.caption).foregroundStyle(Palette.amber)
                                }
                                HStack(spacing: 12) {
                                    ProgressView(value: voyage.progress(at: now)).tint(Palette.amber)
                                    Button(String(localized: "world.travel.locate", defaultValue: "Voir sur la carte")) {
                                        session.selectedTile = voyage.isReturning(at: now) ? voyage.origin : voyage.destination
                                    }
                                    .fixedSize()
                                }
                                .font(.caption)
                            }
                            .padding(12)
                            .background(Palette.panel, in: .rect(cornerRadius: 14))
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                            .foregroundStyle(Palette.amber)
                        Text(String(localized: "world.travel.active", defaultValue: "Voyages en cours"))
                            .font(.subheadline.weight(.semibold))
                        Text(session.state.worldExpeditions.count, format: .number)
                            .font(.caption.bold()).foregroundStyle(Palette.ocean)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Palette.amber, in: .capsule)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: 32)
                }
                .tint(Palette.amber)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Palette.panel, in: .rect(cornerRadius: 16))
            }
        }
    }
}
