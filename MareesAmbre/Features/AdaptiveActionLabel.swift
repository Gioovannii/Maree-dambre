import SwiftUI

struct AdaptiveActionLabel: View {
    let title: String
    let systemImage: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: systemImage).accessibilityHidden(true)
                    Text(title)
                }
            } else {
                Label(title, systemImage: systemImage)
            }
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
