import SwiftUI

struct ExpansionCostView: View {
    let cost: Resources
    @Environment(VillageSession.self) private var session

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { amounts }
            VStack(alignment: .leading, spacing: 8) { amounts }
        }
        .font(.subheadline.bold()).monospacedDigit()
    }

    @ViewBuilder private var amounts: some View {
        amount(String(localized: "screen.resources.wood", defaultValue: "Bois"), cost.wood, session.state.resources.wood, "tree.fill")
        amount(String(localized: "screen.resources.amber", defaultValue: "Ambre"), cost.amber, session.state.resources.amber, "sparkles")
        amount(String(localized: "screen.resources.food", defaultValue: "Vivres"), cost.provisions, session.state.resources.provisions, "basket.fill")
    }
    private func amount(_ name: String, _ required: Int, _ stock: Int, _ icon: String) -> some View {
        Label(required.formatted(), systemImage: icon)
            .foregroundStyle(stock >= required ? Palette.amber : Palette.muted)
            .accessibilityLabel(name + ": " + required.formatted())
    }
}
