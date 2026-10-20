import SwiftUI

struct ExpeditionSupportPanel: View {
    let kind: BuildingKind
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "screen.expedition_support.next_raids", defaultValue: "Prochaines expéditions"))
                .font(.title2.bold())
            if kind == .infirmary {
                LabeledContent(String(localized: "screen.expedition_support.victory_losses", defaultValue: "Pertes en victoire serrée"), value: session.state.victoryLossRate.formatted(.percent))
                LabeledContent(String(localized: "screen.expedition_support.defeat_losses", defaultValue: "Pertes en défaite serrée"), value: session.state.defeatLossRate.formatted(.percent))
                Text(String(localized: "screen.expedition_support.losses_follow_power_ratio", defaultValue: "Ces taux servent de base aux combats serrés. Plus ta force dépasse la défense, plus tes pertes diminuent ; une victoire écrasante peut ne coûter aucune troupe. Les pertes sont arrondies sur toute l’armée."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            } else {
                LabeledContent(String(localized: "screen.expedition_support.transport", defaultValue: "Bonus de transport total"), value: (Double(session.state.transportBonusPercent) / 100).formatted(.percent))
                LabeledContent(String(localized: "screen.expedition_support.loot_limit", defaultValue: "Butin maximum par ressource"), value: "\(session.state.raidLootLimit)")
                Text(String(localized: "screen.expedition_support.loot_rules", defaultValue: "Le butin dépend du transport des survivants et de la place en réserve. Le bonus du Quai s’ajoute à celui des Sauniers."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            Text(String(localized: "screen.expedition_support.departure_rules", defaultValue: "Les bonus sont fixés au départ. Un bâtiment terminé pendant un raid profite au suivant."))
                .font(.footnote).foregroundStyle(Palette.muted)
        }
    }
}
