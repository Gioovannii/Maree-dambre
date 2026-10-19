import SwiftUI

struct ShipmentCargoSummary: View {
    let resources: Resources
    @Environment(\.dynamicTypeSize) private var typeSize
    var body: some View {
        LazyVGrid(columns: typeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: 90))], alignment: .leading, spacing: 10) {
            ForEach(ResourceKind.allCases) { kind in
                Label(resources[kind].formatted(), systemImage: kind.symbol)
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                    .accessibilityLabel(kind.name + ": " + resources[kind].formatted())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
