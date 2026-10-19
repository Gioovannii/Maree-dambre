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
        VStack(alignment: .trailing, spacing: 10) {
            if isExpanded {
                VillageGuideView(people: people, step: step, messages: $messages, onClose: { isExpanded = false },
                                 onShowDestination: onShowDestination)
                    .frame(maxHeight: maximumHeight)
            } else if !hintDismissed && !ProcessInfo.processInfo.arguments.contains("--ui-snapshot") {
                HStack(alignment: .top, spacing: 8) {
                    Button {
                        hintDismissed = true
                        isExpanded = true
                    } label: {
                        Text(String(localized: "guide.hint", defaultValue: "Besoin d’un cap ? Je peux te guider."))
                            .font(.subheadline).multilineTextAlignment(.leading).padding(12)
                    }
                    .buttonStyle(.plain)
                    Button { hintDismissed = true } label: {
                        Image(systemName: "xmark").frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "guide.hide_hint", defaultValue: "Masquer le conseil"))
                }
                .foregroundStyle(Palette.paper)
                .background(Palette.panel, in: .rect(cornerRadius: 18))
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
        .frame(maxWidth: 350, alignment: .trailing)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
    }
}
