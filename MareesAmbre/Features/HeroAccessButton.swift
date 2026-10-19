import SwiftUI

struct HeroAccessButton: View {
    @Environment(VillageSession.self) private var session
    @State private var showsHero = false

    var body: some View {
        Button { showsHero = true } label: {
            HStack(spacing: 7) {
                Image(session.state.hero?.portrait.assetName ?? HeroPortrait.captainWoman.assetName)
                    .resizable().scaledToFill().frame(width: 34, height: 38)
                    .clipShape(.rect(cornerRadius: 10)).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(String(localized: "hero.short_title", defaultValue: "Héros"))
                        .font(.caption.bold())
                    if let hero = session.state.hero {
                        Text(String(localized: "hero.level", defaultValue: "Niveau \(String(hero.level))"))
                            .font(.caption2).foregroundStyle(Palette.amber)
                    } else {
                        Text(String(localized: "hero.short_choose", defaultValue: "Choisir"))
                            .font(.caption2).foregroundStyle(Palette.amber)
                    }
                }
            }
            .padding(.leading, 4).padding(.trailing, 10).padding(.vertical, 4)
            .frame(minHeight: 44)
            .background(Palette.panel, in: .rect(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Palette.amber.opacity(0.5)) }
            .foregroundStyle(Palette.paper)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "hero.open_accessibility", defaultValue: "Ouvrir la fiche de votre héros"))
        .accessibilityIdentifier("hero.globalAccess")
        .sheet(isPresented: $showsHero) { HeroSheet() }
    }
}
