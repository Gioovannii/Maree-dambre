import SwiftUI

struct VillageCompanionOverlay: View {
    let people: People
    let step: VillageGuideStep
    let maximumHeight: CGFloat
    @Binding var isExpanded: Bool
    @State private var messages: [VillageGuideMessage] = []
    let onShowDestination: () -> Void
    @AppStorage("companion.hintDismissed") private var hintDismissed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isExpanded {
                VillageGuideView(people: people, step: step, messages: $messages, onClose: { isExpanded = false },
                                 onShowDestination: onShowDestination)
                    .frame(maxHeight: maximumHeight)
            }

            if !isExpanded {
                Button {
                    hintDismissed = true
                    isExpanded = true
                } label: {
                    Image(VillageGuideView.portrait(for: people))
                        .resizable().scaledToFill().frame(width: 64, height: 64, alignment: .top)
                        .background(Palette.panel, in: Circle()).clipShape(Circle())
                        .overlay { Circle().strokeBorder(Palette.amber, lineWidth: 2) }
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "bubble.left.fill").font(.caption.bold()).padding(5)
                                .foregroundStyle(Palette.ocean).background(Palette.amber, in: Circle())
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "guide.open", defaultValue: "Demander conseil à ton compagnon"))
            }
        }
        .frame(maxWidth: 350, alignment: .leading)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
    }
}
