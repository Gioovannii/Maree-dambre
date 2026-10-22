import SwiftUI

struct HeroAccessButton: View {
    @Environment(VillageSession.self) private var session
    @State private var showsHero = false

    var body: some View {
        Button { showsHero = true } label: {
            Image(session.state.hero?.portrait.assetName ?? HeroPortrait.captainWoman.assetName)
                .resizable().scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(.circle)
                .overlay { Circle().strokeBorder(Palette.amber.opacity(0.7), lineWidth: 1) }
                .overlay(alignment: .bottomTrailing) {
                    if let hero = session.state.hero {
                        Text(hero.level, format: .number)
                            .font(.caption.bold()).monospacedDigit()
                            .foregroundStyle(Palette.ocean)
                            .padding(.horizontal, 5).frame(minHeight: 18)
                            .background(Palette.amber, in: .capsule)
                    }
                }

        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "hero.open_accessibility", defaultValue: "Ouvrir la fiche de votre héros"))
        .accessibilityIdentifier("hero.globalAccess")
        .sheet(isPresented: $showsHero) { HeroSheet() }
    }
}
