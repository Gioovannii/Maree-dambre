import SwiftUI

struct TradeContractsPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsContracts = ProcessInfo.processInfo.arguments.contains("--snapshot-commerce")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(String(localized: "screen.commerce.title", defaultValue: "Contrats maritimes"), systemImage: "shippingbox.fill")
                .font(.headline)
            if let convoy = session.state.army?.convoy {
                Text(String(localized: "screen.commerce.active", defaultValue: "\(String(convoy.units.values.reduce(0, +))) unités en escorte · Retour à la marée \(String(convoy.returnsAtTide))"))
            } else if let reward = session.state.commerce?.report?.pendingAmber, reward > 0 {
                Text(String(localized: "screen.commerce.pending", defaultValue: "Paiement à récupérer : \(String(reward)) ambre"))
            } else {
                Text(String(localized: "screen.commerce.intro", defaultValue: "Livrez du bois au Comptoir des Roseaux. Choisissez une route et gardez assez de troupes pour défendre le port."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            Button { showsContracts = true } label: {
                AdaptiveActionLabel(title: String(localized: "screen.commerce.open", defaultValue: "Voir les contrats"), systemImage: "sailboat.fill")
            }
            .buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 14))
            .accessibilityIdentifier("commerce.open")
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 20))
        .sheet(isPresented: $showsContracts) { TradeContractsView() }
    }
}
