import Foundation

/// Presentation identities for the existing simulated neighbors, never real accounts.
enum WorldNeighbor {
    static func name(for bot: BotFaction, seed: Int) -> String {
        let names = ["Elyan", "Maëlys", "Neris", "Kaëlor", "Sélène", "Orin"]
        let offset = Int(UInt64(truncatingIfNeeded: seed) % UInt64(names.count))
        return names[(offset + bot.id) % names.count]
    }
}
