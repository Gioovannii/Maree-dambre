import SwiftUI

struct ArmyUnitStatsView: View {
    let unit: ArmyUnit
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(String(localized: "unit.stats.attack", defaultValue: "Attaque"),
                           value: session.state.attackStrength(of: unit).formatted())
            LabeledContent(String(localized: "unit.stats.defense", defaultValue: "Défense"),
                           value: session.state.defenseStrength(of: unit).formatted())
            LabeledContent(String(localized: "unit.stats.transport", defaultValue: "Transport"),
                           value: unit.carrying.formatted())
            Text(String(localized: "unit.stats.basis", defaultValue: "Par unité · armes incluses · transport avant bonus"))
                .font(.caption2).foregroundStyle(Palette.muted)
        }
        .font(.footnote)
        .monospacedDigit()
    }
}
