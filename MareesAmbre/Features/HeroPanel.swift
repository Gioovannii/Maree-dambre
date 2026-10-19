import SwiftUI

struct HeroPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var showsHero = ProcessInfo.processInfo.arguments.contains("--snapshot-hero")

    var body: some View {
        Button { showsHero = true } label: {
            HStack(spacing: 14) {
                Image(session.state.hero?.portrait.assetName ?? HeroPortrait.captainWoman.assetName)
                    .resizable().scaledToFill().frame(width: 64, height: 72)
                    .clipShape(.rect(cornerRadius: 12)).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 5) {
                    Text(session.state.hero?.name ?? String(localized: "hero.recruit", defaultValue: "Choisir votre capitaine"))
                        .font(.headline).foregroundStyle(Palette.paper)
                    if let hero = session.state.hero {
                        Text(String(localized: "hero.panel_level", defaultValue: "Niveau \(String(hero.level)) · \(String(hero.totalExperience)) XP"))
                            .font(.caption).foregroundStyle(Palette.amber)
                    } else {
                        Text(String(localized: "hero.panel_hint", defaultValue: "Personnage et personnalisation"))
                            .font(.caption).foregroundStyle(Palette.muted)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(Palette.amber)
            }
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain).accessibilityIdentifier("hero.open")
        .sheet(isPresented: $showsHero) { HeroSheet() }
    }
}
