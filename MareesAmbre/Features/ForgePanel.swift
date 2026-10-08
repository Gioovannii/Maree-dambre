import SwiftUI

struct ForgePanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "screen.forge.title", defaultValue: "Améliorer les armes"))
                .font(.title2.bold())
            LabeledContent(String(localized: "screen.forge.level", defaultValue: "Niveau des armes"), value: "\(session.state.weaponLevel) / \(VillageState.maximumWeaponLevel)")
            Text(String(localized: "screen.forge.effect", defaultValue: "Chaque niveau ajoute 1 point d’attaque à chaque unité. Les améliorations s’appliquent aux expéditions lancées après la fin de la recherche."))
                .font(.footnote).foregroundStyle(Palette.muted)
            if let job = session.state.weaponUpgrade {
                Label(String(localized: "screen.forge.researching", defaultValue: "Recherche en cours"), systemImage: "hourglass")
                Text(timerInterval: min(Date.now, job.endsAt)...job.endsAt, countsDown: true)
                    .monospacedDigit().foregroundStyle(Palette.amber)
            } else if session.state.weaponLevel >= VillageState.maximumWeaponLevel {
                Label(String(localized: "screen.forge.complete", defaultValue: "Armes améliorées au maximum"), systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Palette.amber)
            } else {
                let cost = session.state.weaponUpgradeCost
                Text(String(localized: "screen.forge.cost", defaultValue: "Coût : \(String(cost.wood)) bois · \(String(cost.amber)) ambre · \(String(cost.provisions)) vivres"))
                    .font(.subheadline)
                Button(String(localized: "screen.forge.research", defaultValue: "Rechercher le prochain niveau · 60 s"), systemImage: "hammer.fill", action: session.upgradeWeapons)
                    .buttonStyle(.borderedProminent)
                    .disabled(!session.state.canUpgradeWeapons)
                if !session.state.canUpgradeWeapons {
                    Text(String(localized: "screen.forge.insufficient_resources", defaultValue: "Ressources insuffisantes pour cette recherche."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
            }
        }
        .tint(Palette.amber)
    }
}
