import SwiftUI

struct ResourcesView: View {
    let resources: Resources
    let hourlyProduction: Resources
    let storageCapacity: Int

    var body: some View {
        HStack(spacing: 0) {
            resource(String(localized: "screen.resources.wood", defaultValue: "Bois"), value: resources.wood, rate: hourlyProduction.wood, icon: "tree.fill")
            separator
            resource(String(localized: "screen.resources.amber", defaultValue: "Ambre"), value: resources.amber, rate: hourlyProduction.amber, icon: "sparkles")
            separator
            resource(String(localized: "screen.resources.food", defaultValue: "Vivres"), value: resources.provisions, rate: hourlyProduction.provisions, icon: "basket.fill")
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 6)
        .background(Palette.panel.opacity(0.96), in: .rect(cornerRadius: 16))
    }

    private var separator: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(width: 1, height: 28)
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
    }

    private func resource(_ name: String, value: Int, rate: Int, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(Palette.amber)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 0) {
                Text(String(localized: "screen.resources_view.value", defaultValue: "\(String(value.formatted())) / \(String(storageCapacity.formatted()))"))
                    .font(.caption.bold())
                    .monospacedDigit()
                    .foregroundStyle(Palette.paper)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(value >= storageCapacity ? String(localized: "screen.resources.full", defaultValue: "Plein") : "+\(rate)/h")
                    .font(.caption2.bold())
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.49, green: 0.82, blue: 0.63))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 34, alignment: .center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "screen.resources.value_value_of_value_plus_value_per_hour", defaultValue: "\(String(name)), \(String(value)) sur \(String(storageCapacity)), plus \(String(rate)) par heure"))
    }
}
