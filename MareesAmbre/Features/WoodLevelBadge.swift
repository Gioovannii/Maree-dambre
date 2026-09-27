import SwiftUI

struct WoodLevelBadge: View {
    let level: Int
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.caption.bold())
            }
            Text("\(level)")
                .font(.subheadline.bold())
                .monospacedDigit()
        }
        .foregroundStyle(Color(red: 1, green: 0.94, blue: 0.76))
        .padding(.horizontal, symbol == nil ? 12 : 10)
        .frame(minHeight: symbol == nil ? 29 : 38)
        .background {
            RoundedRectangle(cornerRadius: 9)
                .fill(LinearGradient(
                    colors: [Color(red: 0.50, green: 0.32, blue: 0.18),
                             Color(red: 0.29, green: 0.17, blue: 0.10)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(Color(red: 0.82, green: 0.59, blue: 0.34), lineWidth: 1.5)
        }
        .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
        .accessibilityLabel("Niveau \(level)")
    }
}
