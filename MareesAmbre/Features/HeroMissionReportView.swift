import SwiftUI

struct HeroMissionReportView: View {
    let report: HeroMissionReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(report.mission.title, systemImage: "checkmark.seal.fill")
                .font(.headline).foregroundStyle(Palette.amber)
            Text(String(localized: "hero.mission.xp_gain", defaultValue: "+\(String(report.experience)) XP"))
                .font(.subheadline.bold())
            if report.materials > 0 {
                Label(String(localized: "hero.mission.material_gain", defaultValue: "Matériel maritime : +\(String(report.materials))"), systemImage: "shippingbox.fill")
            }
            if (report.equipment?.highestLevel ?? 0) > 0 {
                Text(String(localized: "hero.equipment.report_bonus", defaultValue: "Bonus d’équipement inclus dans ces récompenses."))
                    .font(.caption).foregroundStyle(Palette.muted)
            }
            if report.boatUnlocked {
                Label(String(localized: "hero.mission.boat_ready", defaultValue: "Votre barque est réparée !"), systemImage: "sailboat.fill")
                    .foregroundStyle(Palette.amber)
                Text(String(localized: "hero.mission.boat_bonus", defaultValue: "La durée de vos missions personnelles est réduite d’un quart. Les armées conservent leurs délais."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
    }
}
