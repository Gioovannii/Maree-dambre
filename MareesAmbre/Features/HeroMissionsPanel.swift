import SwiftUI

struct HeroMissionsPanel: View {
    @Environment(VillageSession.self) private var session
    private var missions: HeroMissions { session.state.hero?.missions ?? HeroMissions() }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(String(localized: "hero.mission.title", defaultValue: "Missions personnelles"), systemImage: "safari.fill")
                .font(.title3.bold()).foregroundStyle(Palette.amber)
            if missions.hasBoat {
                Label(String(localized: "hero.mission.boat_owned", defaultValue: "Barque personnelle"), systemImage: "sailboat.fill")
                    .font(.headline)
                Text(HeroEquipmentKind.sail.effect(at: missions.equipment?.sail ?? 0))
                    .font(.footnote).foregroundStyle(Palette.muted)
            } else {
                Text(String(localized: "hero.mission.chapter", defaultValue: "Votre premier bateau · Étape \(String(missions.chapter + 1)) sur 3"))
                    .font(.headline)
            }
            Label(String(localized: "hero.mission.material_stock", defaultValue: "Matériel maritime : \(String(missions.materials))"), systemImage: "shippingbox.fill")
                .font(.subheadline)
            if let voyage = missions.voyage {
                VStack(alignment: .leading, spacing: 10) {
                    Label(voyage.mission.title, systemImage: "hourglass").font(.headline)
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        let now = ProcessInfo.processInfo.arguments.contains("--ui-snapshot") ? voyage.startedAt : timeline.date
                        Text(GameProgression.durationText(max(0, voyage.endsAt.timeIntervalSince(now))))
                            .monospacedDigit().foregroundStyle(Palette.amber)
                    }
                    Text(voyage.endsAt, format: .dateTime.day().month().hour().minute()).font(.caption)
                    Text(String(localized: "hero.mission.offline", defaultValue: "La mission continue pendant votre absence. Les récompenses et le rapport seront enregistrés au retour."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.ocean, in: .rect(cornerRadius: 16))
                .accessibilityIdentifier("hero.mission.active")
            } else {
                ForEach(missions.available) { mission in HeroMissionCard(mission: mission, missions: missions) }
            }
            Text(String(localized: "hero.mission.single", defaultValue: "Une seule mission à la fois pour tous vos villages. Les coûts sont prélevés au départ ; les missions vont jusqu’à leur terme."))
                .font(.footnote).foregroundStyle(Palette.muted)
            if let report = missions.report {
                Divider()
                HeroMissionReportView(report: report)
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 20))
    }
}
