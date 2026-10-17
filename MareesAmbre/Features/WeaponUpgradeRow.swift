import SwiftUI

struct WeaponUpgradeRow: View {
    let unit: ArmyUnit
    @Environment(VillageSession.self) private var session

    var body: some View {
        let level = session.state.weaponLevel(for: unit)
        VStack(alignment: .leading, spacing: 10) {
            Label(unit.name, systemImage: unit.emblem).font(.headline)
            Text(String(localized: "progression.weapons.level", defaultValue: "Armes : niveau \(String(level)) / \(String(VillageState.maximumWeaponLevel))"))
                .font(.subheadline.bold()).foregroundStyle(Palette.amber)
            Text(String(localized: "progression.weapons.stats", defaultValue: "Attaque : \(String(session.state.attackStrength(of: unit))) · Défense : \(String(session.state.defenseStrength(of: unit))) par unité"))
                .font(.subheadline)
            if level >= VillageState.maximumWeaponLevel {
                Label(String(localized: "screen.forge.complete", defaultValue: "Armes améliorées au maximum"), systemImage: "checkmark.seal.fill")
            } else {
                let cost = session.state.weaponUpgradeCost(for: unit)
                Text(String(localized: "screen.forge.cost", defaultValue: "Coût : \(String(cost.wood)) bois · \(String(cost.amber)) ambre · \(String(cost.provisions)) vivres"))
                    .font(.footnote)
                Text(String(localized: "progression.duration", defaultValue: "Durée : \(String(GameProgression.durationText(session.state.weaponUpgradeDuration(for: unit))))"))
                    .font(.footnote).foregroundStyle(Palette.muted)
                Button(String(localized: "progression.weapons.upgrade", defaultValue: "Améliorer les armes au niveau \(String(level + 1))"), systemImage: "hammer.fill") {
                    session.upgradeWeapons(for: unit)
                }
                .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                .disabled(!session.state.canUpgradeWeapons(for: unit))
                .accessibilityIdentifier("forge.upgrade.\(unit.rawValue)")
                if !session.state.unlockedUnits.contains(unit) {
                    Text(String(localized: "screen.army.unlock_at_the_academy", defaultValue: "À débloquer à la Maison des savoirs"))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if session.state.buildingLevel(.forge) < level + 1 {
                    Text(String(localized: "progression.weapons.forge_required", defaultValue: "Requiert la Forge au niveau \(String(level + 1))."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if session.state.weaponUpgrade != nil {
                    Text(String(localized: "progression.weapons.busy", defaultValue: "Terminez la recherche d’armes en cours."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if !session.state.canUpgradeWeapons(for: unit) {
                    Text(String(localized: "screen.forge.insufficient_resources", defaultValue: "Ressources insuffisantes pour cette recherche."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                if max(cost.wood, cost.amber, cost.provisions) > session.state.storageCapacity {
                    Text(String(localized: "progression.storage_required", defaultValue: "Améliorez l’Entrepôt pour pouvoir stocker les ressources nécessaires."))
                        .font(.footnote).foregroundStyle(Palette.amber)
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.ocean, in: .rect(cornerRadius: 16))
    }
}
