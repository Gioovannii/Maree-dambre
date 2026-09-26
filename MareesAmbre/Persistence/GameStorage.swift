import Foundation

struct GameStorage {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func load(seed: Int) throws -> GameState? {
        guard let data = defaults.data(forKey: "archipelago.v1.\(seed)") else { return nil }
        let state = try JSONDecoder().decode(GameState.self, from: data)
        guard state.version == GameState.rulesVersion, state.seed == seed,
              state.islands.map(\.id) == Array(0...4),
              state.resources.wood >= 0, state.resources.amber >= 0,
              state.resources.provisions >= 0, state.turn >= 1,
              state.islands.allSatisfy({ (0...4).contains($0.portLevel) }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        return state
    }

    func save(_ state: GameState) throws {
        defaults.set(try JSONEncoder().encode(state), forKey: "archipelago.v1.\(state.seed)")
    }
}
