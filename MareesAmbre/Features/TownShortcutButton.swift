import SwiftUI

struct TownShortcutButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(String(localized: "screen.village_board.quay_town", defaultValue: "Quais & Centre"), systemImage: "sailboat.fill")
                .font(.caption.bold())
                .foregroundStyle(Palette.paper)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .background(Palette.panel, in: .capsule)
                .overlay { Capsule().strokeBorder(Palette.amber.opacity(0.8), lineWidth: 1.5) }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("village.openTown")
        .accessibilityHint(String(localized: "screen.village_board.open_the_harbor_and_town_buildings", defaultValue: "Ouvrir le port et les bâtiments du Centre-ville"))
    }
}
