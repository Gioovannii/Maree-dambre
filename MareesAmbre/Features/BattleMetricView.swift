import SwiftUI

struct BattleMetricView: View {
    let title: String
    let value: Int
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).font(.title3).foregroundStyle(color).accessibilityHidden(true)
            Text(title).font(.caption.bold()).foregroundStyle(color)
            Text(value.formatted()).font(.title.bold()).monospacedDigit().foregroundStyle(Palette.paper)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.1), in: .rect(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(color.opacity(0.3)) }
        .accessibilityElement(children: .combine)
    }
}
