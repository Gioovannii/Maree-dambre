import SwiftUI

/// Level marker for Ambre's coastal resource sites and city buildings.
/// Its sea-glass and amber palette gives the game its own visual language.
struct TideLevelBadge: View {
    let level: Int
    var symbol: String? = nil

    var selected = false

    var body: some View {
        HStack(spacing: 4) {
            if let symbol { Image(systemName: symbol) }
            Text(String(localized: "screen.tide_level_badge.value", defaultValue: "\(String(level))"))
                .monospacedDigit()
            if selected { Image(systemName: "checkmark") }
        }
        .font(.subheadline.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .foregroundStyle(selected ? Palette.ocean : Palette.paper)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minWidth: 28, minHeight: 28)
        .background(selected ? Palette.amber : Palette.panel, in: .capsule)
        .overlay { Capsule().strokeBorder(selected ? Palette.ocean : Palette.paper, lineWidth: 1) }
        .shadow(color: Palette.ocean.opacity(0.5), radius: 2, y: 2)
        .accessibilityLabel(String(localized: "screen.tide_level_badge.level_value", defaultValue: "Niveau \(String(level))"))
    }
}
