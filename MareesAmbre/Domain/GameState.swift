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
            Island(id: 0, name: L10n.text("Port d’Ambre", "Amber Harbor"), subtitle: L10n.text("Votre foyer · Ligue des Veilleurs", "Your home · League of Watchers"), x: 0.30, y: 0.52, isHome: true, portLevel: 1),
            Island(id: 1, name: L10n.text("Les Brumes", "The Mists"), subtitle: L10n.text("Forêts silencieuses", "Silent forests"), x: 0.24 + offset, y: 0.18, isHome: false, portLevel: 0),
            Island(id: 2, name: L10n.text("Éclat", "Gleam"), subtitle: L10n.text("Récifs ambrés", "Amber reefs"), x: 0.72, y: 0.30, isHome: false, portLevel: 0),
            Island(id: 3, name: L10n.text("Sillage", "Wake"), subtitle: L10n.text("Terres fertiles", "Fertile lands"), x: 0.68 + offset / 2, y: 0.72, isHome: false, portLevel: 0),
            Island(id: 4, name: L10n.text("Le Refuge", "The Refuge"), subtitle: L10n.text("Havre inexploré", "Unexplored haven"), x: 0.24, y: 0.86, isHome: false, portLevel: 0)
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
