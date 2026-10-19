import SwiftUI

struct ResourcesView: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showsForecast = ProcessInfo.processInfo.arguments.contains("--snapshot-storage")
    let resources: Resources
    let hourlyProduction: Resources
    let storageCapacity: Int

    var body: some View {
        Button {
            showsForecast = true
        } label: {
            VStack(spacing: 4) {
                resourceLayout {
                    resource(String(localized: "screen.resources.wood", defaultValue: "Bois"), value: resources.wood, rate: hourlyProduction.wood, icon: "tree.fill")
                    separator
                    resource(String(localized: "screen.resources.amber", defaultValue: "Ambre"), value: resources.amber, rate: hourlyProduction.amber, icon: "sparkles")
                    separator
                    resource(String(localized: "screen.resources.food", defaultValue: "Vivres"), value: resources.provisions, rate: hourlyProduction.provisions, icon: "basket.fill")
                }
                Label(String(localized: "storage.forecast.open", defaultValue: "Prévoir mes réserves"), systemImage: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(Palette.muted)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showsForecast) {
            StorageForecastSheet(resources: resources, hourlyProduction: hourlyProduction, capacity: storageCapacity)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 6)
        .background(Palette.panel, in: .rect(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.amber.opacity(0.35), lineWidth: 1) }
    }

    private var resourceLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 0))
            : AnyLayout(HStackLayout(spacing: 0))
    }

    private var separator: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(width: typeSize.isAccessibilitySize ? nil : 1, height: typeSize.isAccessibilitySize ? 1 : 28)
            .padding(.horizontal, typeSize.isAccessibilitySize ? 0 : 4)
            .padding(.vertical, typeSize.isAccessibilitySize ? 4 : 0)
            .accessibilityHidden(true)
    }

    private func resource(_ name: String, value: Int, rate: Int, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(Palette.amber)
                .frame(width: typeSize.isAccessibilitySize ? nil : 18)
            VStack(alignment: .leading, spacing: 0) {
                Text(String(localized: "screen.resources_view.value", defaultValue: "\(String(value.formatted())) / \(String(storageCapacity.formatted()))"))
                    .font(.caption.bold())
                    .monospacedDigit()
                    .foregroundStyle(Palette.paper)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 1)
                    .minimumScaleFactor(typeSize.isAccessibilitySize ? 1 : 0.8)
                    .fixedSize(horizontal: false, vertical: true)
                Text(value >= storageCapacity ? String(localized: "screen.resources.full", defaultValue: "Plein") : "+\(rate)/h")
                    .font(.caption2.bold())
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.49, green: 0.82, blue: 0.63))
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 1)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 34, alignment: typeSize.isAccessibilitySize ? .leading : .center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "screen.resources.value_value_of_value_plus_value_per_hour", defaultValue: "\(String(name)), \(String(value)) sur \(String(storageCapacity)), plus \(String(rate)) par heure"))
    }
}
