import SwiftUI

struct ShipmentResourceRow: View {
    let kind: ResourceKind
    @Binding var amount: Int
    let stock: Int
    @FocusState.Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(kind.name, systemImage: kind.symbol).foregroundStyle(Palette.amber)
            TextField(kind.name, value: $amount, format: .number)
                .focused($isEditing).keyboardType(.numberPad).textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("shipment.cargo.\(kind.rawValue)")
            HStack {
                Text(String(localized: "shipment.available", defaultValue: "Disponible"))
                Text(stock.formatted()).monospacedDigit()
                Spacer(minLength: 8)
                Button(String(localized: "shipment.maximum", defaultValue: "Maximum")) { amount = stock }
                    .buttonStyle(.bordered)
            }
            .font(.footnote)
        }
    }
}
