import SwiftUI

struct ResourcesView: View {
    let resources: Resources
    let hourlyProduction: Resources
    let storageCapacity: Int

    var body: some View {
        HStack(spacing: 0) {
            resource("Bois", value: resources.wood, rate: hourlyProduction.wood, icon: "tree.fill")
            separator
            resource("Ambre", value: resources.amber, rate: hourlyProduction.amber, icon: "sparkles")
            separator
            resource("Vivres", value: resources.provisions, rate: hourlyProduction.provisions, icon: "basket.fill")
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 9)
        .background(Palette.panel.opacity(0.97), in: .rect(cornerRadius: 18))
    }

    private var separator: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(width: 1, height: 42)
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
    }

    private func resource(_ name: String, value: Int, rate: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(Palette.amber)
                Text(name.uppercased())
                    .font(.caption2.bold())
                    .tracking(0.7)
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Text("\(value.formatted()) / \(storageCapacity.formatted())")
                .font(.headline.bold())
                .monospacedDigit()
                .foregroundStyle(Palette.paper)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text("+\(rate)/h")
                .font(.caption2.bold())
                .monospacedDigit()
                .foregroundStyle(Color(red: 0.49, green: 0.82, blue: 0.63))
        }
        .frame(maxWidth: .infinity, minHeight: 59, alignment: .leading)
        .padding(.horizontal, 5)
        .accessibilityElement(children: .combine)
    }
}
