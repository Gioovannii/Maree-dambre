import SwiftUI

struct MarketPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var source: ResourceKind = .wood
    @State private var destination: ResourceKind = .provisions
    @State private var lots = 1
    @State private var showsContracts = false

    private var received: Int { session.state.tradeReturn(from: source, to: destination, lots: lots) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "screen.market.title", defaultValue: "Échanger des ressources"))
                .font(.title2.bold())
            Text(String(localized: "screen.market.rules", defaultValue: "L’ambre vaut deux fois le bois ou les vivres. Le marché conserve la moitié de la valeur échangée. Un échange est refusé si la réserve d’arrivée est pleine."))
                .font(.footnote).foregroundStyle(Palette.muted)
            LabeledContent(String(localized: "screen.market.give", defaultValue: "Donner")) {
                Picker(String(localized: "screen.market.give", defaultValue: "Donner"), selection: $source) {
                    ForEach(ResourceKind.allCases) { kind in Text(kind.name).tag(kind) }
                }
                .pickerStyle(.menu).labelsHidden()
            }
            LabeledContent(String(localized: "screen.market.receive", defaultValue: "Recevoir")) {
                Picker(String(localized: "screen.market.receive", defaultValue: "Recevoir"), selection: $destination) {
                    ForEach(ResourceKind.allCases) { kind in Text(kind.name).tag(kind) }
                }
                .pickerStyle(.menu).labelsHidden()
            }
            Stepper(String(localized: "screen.market.lots", defaultValue: "Lots de 20 : \(String(lots))"), value: $lots, in: 1...10)
            LabeledContent(source.name, value: "−\(lots * 20)")
            LabeledContent(destination.name, value: "+\(received)")
                .foregroundStyle(Palette.amber)
            if source == destination {
                Text(String(localized: "screen.market.different_resources", defaultValue: "Choisissez deux ressources différentes."))
                    .font(.footnote)
            } else if session.state.resources[source] < lots * 20 {
                Text(String(localized: "screen.market.insufficient_stock", defaultValue: "Stock insuffisant pour cet échange."))
                    .font(.footnote)
            } else if session.state.resources[destination] > session.state.storageCapacity - received {
                Text(String(localized: "screen.market.insufficient_capacity", defaultValue: "La réserve d’arrivée manque de place. Réduisez le nombre de lots."))
                    .font(.footnote)
            }
            Button(String(localized: "screen.market.exchange", defaultValue: "Confirmer l’échange"), systemImage: "arrow.left.arrow.right", action: exchange)
                .buttonStyle(.borderedProminent)
                .foregroundStyle(Palette.ocean)
                .disabled(!session.state.canTrade(from: source, to: destination, lots: lots))
            Button { showsContracts = true } label: {
                AdaptiveActionLabel(title: String(localized: "screen.commerce.open", defaultValue: "Voir les contrats"), systemImage: "sailboat.fill")
            }
            .buttonStyle(.bordered).buttonBorderShape(.roundedRectangle(radius: 14))
            .accessibilityIdentifier("commerce.open")
        }
        .tint(Palette.amber)
        .sheet(isPresented: $showsContracts) { TradeContractsView() }
    }

    private func exchange() { session.trade(from: source, to: destination, lots: lots) }
}
