import SwiftUI

struct DefenseReportView: View {
    let report: DefenseReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(report.won
                  ? String(localized: "screen.defense.held", defaultValue: "Port défendu")
                  : String(localized: "screen.defense.breached", defaultValue: "Défense percée"),
                  systemImage: report.won ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.headline)
            Text(String(localized: "screen.defense.comparison", defaultValue: "Défense : \(String(report.garrisonPower)) · Assaut : \(String(report.enemyPower))"))
            Text(String(localized: "screen.defense.fortifications", defaultValue: "Fortifications et peuple : \(String(report.fortificationPower)) points inclus dans la défense."))
                .font(.footnote).foregroundStyle(Palette.muted)
            Text(String(localized: "screen.defense.losses", defaultValue: "Pertes dans la garnison : \(String(report.lossCount))"))
            ForEach(ArmyUnit.allCases.filter { report.losses[$0, default: 0] > 0 }) { unit in
                Text(String(localized: "screen.defense.unit_losses", defaultValue: "\(String(unit.name)) : \(String(report.losses[unit, default: 0])) perte(s)"))
                    .font(.footnote)
            }
            Text(String(localized: "screen.defense.stolen", defaultValue: "Stocks pillés : \(String(report.stolen.wood)) bois · \(String(report.stolen.amber)) ambre · \(String(report.stolen.provisions)) vivres"))
                .font(.subheadline)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
