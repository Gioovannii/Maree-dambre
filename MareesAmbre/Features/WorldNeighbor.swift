import Foundation

/// Presentation identities for the existing simulated neighbors, never real accounts.
enum WorldNeighbor {
    static func name(for bot: BotFaction, seed: Int) -> String {
        bot.pseudonym(seed: seed)
    }
}
