import Foundation

struct GameState: Codable, Equatable {
    static let rulesVersion = 1
    var version = rulesVersion
    let seed: Int
    var resources = Resources()
    var turn = 1
    var islands: [Island]

    init(seed: Int) {
        self.seed = seed
        // Integer mixing is explicitly stable; never use Swift's randomized hashValue.
        let offset = Double((UInt64(max(seed, 0)) &* 1_664_525 &+ 1_013_904_223) % 11) / 100
        islands = [
            Island(id: 0, name: String(localized: "domain.game_state.amber_harbor", defaultValue: "Port d’Ambre"), subtitle: String(localized: "domain.game_state.your_home_league_of_watchers", defaultValue: "Votre foyer · Ligue des Veilleurs"), x: 0.30, y: 0.52, isHome: true, portLevel: 1),
            Island(id: 1, name: String(localized: "domain.game_state.the_mists", defaultValue: "Les Brumes"), subtitle: String(localized: "domain.game_state.silent_forests", defaultValue: "Forêts silencieuses"), x: 0.24 + offset, y: 0.18, isHome: false, portLevel: 0),
            Island(id: 2, name: String(localized: "domain.game_state.gleam", defaultValue: "Éclat"), subtitle: String(localized: "domain.game_state.amber_reefs", defaultValue: "Récifs ambrés"), x: 0.72, y: 0.30, isHome: false, portLevel: 0),
            Island(id: 3, name: String(localized: "domain.game_state.wake", defaultValue: "Sillage"), subtitle: String(localized: "domain.game_state.fertile_lands", defaultValue: "Terres fertiles"), x: 0.68 + offset / 2, y: 0.72, isHome: false, portLevel: 0),
            Island(id: 4, name: String(localized: "domain.game_state.the_refuge", defaultValue: "Le Refuge"), subtitle: String(localized: "domain.game_state.unexplored_haven", defaultValue: "Havre inexploré"), x: 0.24, y: 0.86, isHome: false, portLevel: 0)
        ]
    }

    func developmentCost(for id: Int) -> Resources? {
        guard let island = islands.first(where: { $0.id == id }), island.isHome, island.portLevel < 4 else { return nil }
        return Resources(wood: island.portLevel * 20, amber: island.portLevel * 10, provisions: 0)
    }

    func canDevelop(_ id: Int) -> Bool {
        guard let cost = developmentCost(for: id) else { return false }
        return resources.wood >= cost.wood && resources.amber >= cost.amber
    }

    @discardableResult
    mutating func develop(_ id: Int) -> Bool {
        guard canDevelop(id), let cost = developmentCost(for: id),
              let index = islands.firstIndex(where: { $0.id == id }) else { return false }
        resources.wood -= cost.wood
        resources.amber -= cost.amber
        islands[index].portLevel += 1
        turn += 1
        return true
    }
}
