import SwiftUI

struct RaidOutcomePreview: View {
    let units: [ArmyUnit: Int]
    let defense: Int
    @Environment(VillageSession.self) private var session

    var body: some View {
        Text(session.state.armyPower(for: units) > defense
             ? String(localized: "screen.army.victory_with_support", defaultValue: "Victoire prévue. Pertes : \(String(session.state.victoryLossRate(for: units).formatted(.percent.precision(.fractionLength(0))))) arrondies à l’entier inférieur par type. Butin : jusqu’à \(String(session.state.raidLootLimit)) de chaque ressource, selon le transport des survivants et la place en réserve.")
             : String(localized: "screen.army.defeat_with_support", defaultValue: "Défaite prévue. Pertes : \(String(session.state.defeatLossRate.formatted(.percent.precision(.fractionLength(0))))) arrondies à l’entier supérieur par type. Aucun butin."))
            .font(.footnote)
            .accessibilityIdentifier("raid.outcome")
    }
}
