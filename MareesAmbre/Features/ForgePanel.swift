import SwiftUI

struct ForgePanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "screen.forge.title", defaultValue: "Améliorer les armes"))
                .font(.title2.bold())
            Text(String(localized: "progression.forge.explanation", defaultValue: "Choisissez le type d’unité à équiper. Chaque niveau ajoute 1 point d’attaque et de défense à ses unités actuelles et futures. Le niveau de la Forge limite celui des armes. Les troupes déjà parties conservent leur équipement de départ."))
                .font(.footnote).foregroundStyle(Palette.muted)
            if let job = session.state.weaponUpgrade {
                Label(String(localized: "screen.forge.researching", defaultValue: "Recherche en cours"), systemImage: "hourglass")
                Text(timerInterval: min(Date.now, job.endsAt)...job.endsAt, countsDown: true)
                    .monospacedDigit().foregroundStyle(Palette.amber)
                Text(job.unit?.name ?? String(localized: "progression.forge.legacy", defaultValue: "Recherche commune déjà engagée"))
                    .font(.subheadline)
            }
            ForEach(session.state.trainableUnits) { unit in
                WeaponUpgradeRow(unit: unit)
            }
        }
        .tint(Palette.amber)
    }
}
