import SwiftUI

/// Level marker for Ambre's coastal resource sites and city buildings.
/// Its sea-glass and amber palette gives the game its own visual language.
struct TideLevelBadge: View {
    let level: Int
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.caption.bold())
            }
            // The number alone stays legible at small sizes; the capsule already
            // communicates that this is a level marker and avoids “N0” reading
            // like the word “NO” on compact screens.
            Text(String(localized: "screen.tide_level_badge.value", defaultValue: "\(String(level))"))
                .font(.subheadline.bold())
                .monospacedDigit()
        }
        .foregroundStyle(Palette.paper)
        .padding(.horizontal, symbol == nil ? 12 : 10)
        .frame(minHeight: symbol == nil ? 29 : 38)
        .background {
            Capsule()
                .fill(LinearGradient(
                    colors: [Palette.panel, Color(red: 0.02, green: 0.34, blue: 0.40)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
        .overlay {
            Capsule()
                .strokeBorder(Palette.amber, lineWidth: 1.5)
        }
        .shadow(color: Palette.ocean.opacity(0.55), radius: 3, y: 2)
        .accessibilityLabel(String(localized: "screen.tide_level_badge.level_value", defaultValue: "Niveau \(String(level))"))
    }
}
