import SwiftUI

struct RaidOutcomePreview: View {
    let units: [ArmyUnit: Int]
    let defense: Int
    @Environment(VillageSession.self) private var session

    var body: some View {
        let won = session.state.armyPower(for: units) > defense
        let rate = RaidOrder.casualtyRate(
            attackPower: session.state.armyPower(for: units),
            defense: defense,
            won: won,
            supportMultiplier: won
                ? session.state.victoryLossRate(for: units) / 0.2
                : session.state.defeatLossRate / 0.5
        )
        let losses = RaidOrder.casualties(units: units, rate: rate, roundUp: !won).values.reduce(0, +)
        VStack(alignment: .leading, spacing: 4) {
            Text(won ? "Victoire prévue · \(losses) perte(s) sur \(units.values.reduce(0, +)) troupes." : "Défaite prévue · \(losses) perte(s) sur \(units.values.reduce(0, +)) troupes. Aucun butin.")
            if won {
                Text("Butin : jusqu’à \(session.state.raidLootLimit) de chaque ressource, selon le transport des survivants et la place en réserve.")
            }
            Text("Les pertes sont calculées sur toute l’armée, pas arrondies séparément pour chaque type d’unité.")
                .foregroundStyle(Palette.muted)
        }
        .font(.footnote)
        .accessibilityIdentifier("raid.outcome")
    }
}
