import SwiftUI

struct HeroExperienceView: View {
    let hero: PlayerHero

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "hero.level", defaultValue: "Niveau \(String(hero.level))"), systemImage: "star.circle.fill")
                .font(.title3.bold()).foregroundStyle(Palette.amber)
            if hero.isMaximumLevel {
                Text(String(localized: "hero.maximum_level", defaultValue: "Niveau maximum atteint"))
                    .font(.subheadline.bold())
            } else {
                ProgressView(value: Double(hero.experienceInLevel), total: Double(hero.experienceForNextLevel)) {
                    Text(String(localized: "hero.level_progress", defaultValue: "\(String(hero.experienceInLevel)) / \(String(hero.experienceForNextLevel)) XP vers le prochain niveau"))
                        .font(.subheadline).monospacedDigit()
                }.tint(Palette.amber)
            }
            Text(String(localized: "hero.total_xp", defaultValue: "Expérience totale : \(String(hero.totalExperience)) XP"))
                .font(.caption).foregroundStyle(Palette.muted)
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 18))
        .accessibilityIdentifier("hero.experience")
    }
}
