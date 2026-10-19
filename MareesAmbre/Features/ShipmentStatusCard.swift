import SwiftUI

struct ShipmentStatusCard: View {
    let source: VillageState
    let order: SettlementShipment
    @Environment(VillageSession.self) private var session

    private var arrived: Bool { (source.lastProductionAt ?? .distantPast) >= order.arrivesAt }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(source.settlementName + " → " + session.settlementName(at: order.destination), systemImage: "shippingbox.fill")
                .font(.headline).foregroundStyle(Palette.amber)
            Text("\(source.location.x), \(source.location.y) → \(order.destination.x), \(order.destination.y)")
                .font(.caption).foregroundStyle(Palette.muted)
            if order.isComplete {
                Label(String(localized: "shipment.complete", defaultValue: "Cargaison livrée · escorte rentrée"), systemImage: "checkmark.circle.fill")
            } else {
                if !arrived {
                    Text(String(localized: "shipment.arrives_in", defaultValue: "Livraison dans"))
                    Text(order.arrivesAt, style: .timer).monospacedDigit()
                } else if order.unloaded != order.cargo {
                    Label(String(localized: "shipment.waiting", defaultValue: "Surplus en attente de place à destination"), systemImage: "shippingbox.and.arrow.backward.fill")
                    ShipmentCargoSummary(resources: order.remaining)
                } else {
                    Label(String(localized: "shipment.delivered", defaultValue: "Cargaison livrée"), systemImage: "checkmark.circle.fill")
                }
                if order.escortReturned {
                    Text(String(localized: "shipment.returned", defaultValue: "L’escorte est rentrée au village de départ."))
                } else {
                    Text(String(localized: "shipment.returns_in", defaultValue: "Retour de l’escorte dans"))
                    Text(order.returnsAt, style: .timer).monospacedDigit()
                }
            }
            Text(String(localized: "shipment.sent_cargo", defaultValue: "Cargaison envoyée"))
                .font(.caption).foregroundStyle(Palette.muted)
            ShipmentCargoSummary(resources: order.cargo)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 18))
    }
}
