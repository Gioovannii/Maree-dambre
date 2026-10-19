import SwiftUI

struct HeroMissionCard: View {
    let mission: HeroMissionKind
    let missions: HeroMissions
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(mission.title, systemImage: mission.symbol).font(.headline)
            Text(mission.summary).font(.subheadline).foregroundStyle(Palette.muted)
            Label(GameProgression.durationText(missions.duration(for: mission)), systemImage: "clock")
                .font(.subheadline.bold()).foregroundStyle(Palette.amber)
            if missions.hasBoat {
                Text(String(localized: "hero.mission.duration_boat", defaultValue: "Durée avec votre barque"))
                    .font(.caption).foregroundStyle(Palette.muted)
            }
            Text(String(localized: "hero.mission.reward_xp", defaultValue: "Récompense : \(String(mission.experience)) XP"))
                .font(.subheadline)
            if mission.materials > 0 {
                Label(String(localized: "hero.mission.material_gain", defaultValue: "Matériel maritime : +\(String(mission.materials))"), systemImage: "shippingbox.fill")
                    .font(.subheadline)
            }
            if mission == .repairBoat {
                Label(String(localized: "hero.mission.boat_unlock", defaultValue: "Débloque votre barque et les missions maritimes"), systemImage: "sailboat.fill")
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                Text(String(localized: "hero.mission.repair_cost", defaultValue: "Coût : 5 unités de matériel maritime et ressources du village sélectionné."))
                    .font(.footnote)
                ExpansionCostView(cost: mission.cost)
                Text(session.state.settlementName).font(.caption).foregroundStyle(Palette.muted)
            }
            Button {
                _ = session.startHeroMission(mission)
            } label: {
                Label(String(localized: "hero.mission.start", defaultValue: "Lancer la mission"), systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity).padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
            .disabled(!session.state.canStartHeroMission(mission))
            .accessibilityIdentifier("hero.mission.start.\(mission.rawValue)")
            if !session.state.canStartHeroMission(mission) {
                Text(String(localized: "hero.mission.insufficient", defaultValue: "Ressources ou matériel insuffisants dans ce village."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.ocean, in: .rect(cornerRadius: 16))
    }
}
