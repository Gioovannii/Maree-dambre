import SwiftUI

struct ShipmentPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsShipment = false
    var body: some View {
        if session.state.settlementCount > 1 {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "shipment.title", defaultValue: "Ravitaillement")).font(.title3.bold())
                Text(String(localized: "shipment.intro", defaultValue: "Envoyez des ressources vers vos autres villages. Un transport peut être engagé par village."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                Button(String(localized: "shipment.prepare", defaultValue: "Préparer un ravitaillement"), systemImage: "shippingbox.fill") { showsShipment = true }
                    .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                    .accessibilityIdentifier("shipment.prepare")
                ForEach([session.state] + (session.state.otherVillages ?? []), id: \.location) { source in
                    if let order = source.shipment {
                        ShipmentStatusCard(source: source, order: order)
                    }
                }
            }
            .sheet(isPresented: $showsShipment) { ShipmentView() }
        }
    }
}
