import SwiftUI

struct ConvoyReportView: View {
    let report: ConvoyReport
    var isPreview = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(report.successful
                  ? (isPreview ? String(localized: "screen.commerce.success_expected", defaultValue: "Livraison prévue")
                     : String(localized: "screen.commerce.delivered", defaultValue: "Livraison accomplie"))
                  : (isPreview ? String(localized: "screen.commerce.failure_expected", defaultValue: "Convoi en danger : cargaison perdue prévue")
                     : String(localized: "screen.commerce.lost", defaultValue: "Cargaison perdue")),
                  systemImage: report.successful ? "checkmark.seal.fill" : "exclamationmark.shield.fill")
                .font(.headline)
            Text(String(localized: "screen.commerce.escort_result", defaultValue: "Escorte de retour : \(String(report.returnedCount)) · Pertes : \(String(report.lossCount))"))
            Text(String(localized: "screen.commerce.payment", defaultValue: "Paiement : \(String(report.amberReward)) ambre"))
            ForEach(ArmyUnit.allCases.filter { report.losses(of: $0) > 0 }) { unit in
                Text(String(localized: "screen.defense.unit_losses", defaultValue: "\(String(unit.name)) : \(String(report.losses(of: unit))) perte(s)"))
                    .font(.footnote)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
