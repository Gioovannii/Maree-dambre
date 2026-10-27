import SwiftUI

struct VillageCompanionOverlay: View {
    let people: People
    let step: VillageGuideStep
    let maximumHeight: CGFloat
    @Binding var isExpanded: Bool
    @State private var messages: [VillageGuideMessage] = []
    var allowsTutorial = true
    @State private var showsHero = false
    let onShowDestination: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if isExpanded {
                VillageGuideView(people: people, step: step, messages: $messages, onClose: { isExpanded = false },
                                 onShowDestination: onShowDestination)
                    .frame(maxHeight: maximumHeight)
            }

            if !isExpanded {
                Button {
                    if allowsTutorial { isExpanded = true }
                    else { showsHero = true }
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
                .accessibilityIdentifier("companion.open")
                .accessibilityLabel(allowsTutorial
                    ? String(localized: "guide.open", defaultValue: "Demander conseil à ton compagnon")
                    : String(localized: "hero.open_accessibility", defaultValue: "Ouvrir la fiche de votre héros"))
            }
        }
        .frame(maxWidth: 350, alignment: .trailing)
        .sheet(isPresented: $showsHero) { HeroSheet() }
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
    }
}
