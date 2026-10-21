import SwiftUI

struct RaidOutcomePreview: View {
    let units: [ArmyUnit: Int]
    let defense: Int
    var heroAttackBonus = 0
    @Environment(VillageSession.self) private var session

    var body: some View {
        let power = session.state.armyPower(for: units) + heroAttackBonus
        let won = power > defense
        let rate = RaidOrder.casualtyRate(
            attackPower: power,
            defense: defense,
            won: won,
            supportMultiplier: won
                ? session.state.victoryLossRate(for: units) / 0.2
                : session.state.defeatLossRate / 0.5
        )
        let losses = RaidOrder.casualties(units: units, rate: rate, roundUp: !won).values.reduce(0, +)
        VStack(alignment: .leading, spacing: 4) {
            Text(won
                 ? String(localized: "raid.preview.win", defaultValue: "Victoire prévue · \(String(losses)) perte(s) sur \(String(units.values.reduce(0, +))) troupes.")
                 : String(localized: "raid.preview.loss", defaultValue: "Défaite prévue · \(String(losses)) perte(s) sur \(String(units.values.reduce(0, +))) troupes. Aucun butin."))
            if won {
                Text(String(localized: "raid.preview.loot", defaultValue: "Butin : jusqu’à \(String(session.state.raidLootLimit)) de chaque ressource, selon le transport des survivants et la place en réserve."))
            }
            Text(String(localized: "raid.preview.rounding", defaultValue: "Les pertes sont calculées sur toute l’armée, pas arrondies séparément pour chaque type d’unité."))
                .foregroundStyle(Palette.muted)
        }
        .font(.footnote)
        .accessibilityIdentifier("raid.outcome")
    }
}
