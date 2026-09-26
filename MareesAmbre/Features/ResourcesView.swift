import SwiftUI

struct ResourcesView: View {
    let resources: Resources
    let hourlyProduction: Resources
    let storageCapacity: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 9) { resource("Bois", value: resources.wood, rate: hourlyProduction.wood, icon: "tree.fill"); resource("Ambre", value: resources.amber, rate: hourlyProduction.amber, icon: "sparkles"); resource("Vivres", value: resources.provisions, rate: hourlyProduction.provisions, icon: "basket.fill") }
            VStack(spacing: 8) { HStack(spacing: 8) { resource("Bois", value: resources.wood, rate: hourlyProduction.wood, icon: "tree.fill"); resource("Ambre", value: resources.amber, rate: hourlyProduction.amber, icon: "sparkles") }; resource("Vivres", value: resources.provisions, rate: hourlyProduction.provisions, icon: "basket.fill") }
        }
    }

    private func resource(_ name: String, value: Int, rate: Int, icon: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon).font(.headline).foregroundStyle(Palette.amber).frame(width: 23)
            VStack(alignment: .leading, spacing: 2) {
                Text(name.uppercased()).font(.caption.bold()).tracking(1).foregroundStyle(Palette.muted)
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(value.formatted())/\(storageCapacity.formatted())")
                        .font(.title3.bold()).monospacedDigit().foregroundStyle(Palette.paper)
                    Text("+\(rate)/h").font(.caption).foregroundStyle(Color(red: 0.49, green: 0.82, blue: 0.63))
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 13).padding(.vertical, 10)
        .background(Palette.panel, in: .capsule)
        .accessibilityElement(children: .combine)
    }
}
