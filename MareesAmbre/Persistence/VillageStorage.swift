import Foundation

struct VillageStorage {
    func load(seed: Int) throws -> VillageState? {
        guard let data = UserDefaults.standard.data(forKey: "village.v2.\(seed)") else { return nil }
        let state = try JSONDecoder().decode(VillageState.self, from: data)
        guard (2...7).contains(state.version), state.seed == seed,
              state.resources.wood >= 0, state.resources.amber >= 0, state.resources.provisions >= 0,
              state.resources.wood <= 999_999, state.resources.amber <= 999_999, state.resources.provisions <= 999_999,
              state.buildings[12] == .hall,
              state.buildings.allSatisfy({ (0..<25).contains($0.key) && ($0.value != .hall || $0.key == 12) }),
              state.bots.map(\.id) == [0, 1, 2],
              state.bots.allSatisfy({ $0.capital.isValid && $0.territory.count <= 64 && $0.territory.contains($0.capital) && $0.territory.allSatisfy(\.isValid) }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        var migrated = state
        migrated.migrateIfNeeded()
        guard migrated.buildings.allSatisfy({ VillageState.canLoad($0.value, at: $0.key) || ($0.value == .hall && $0.key == 12) }),
              (migrated.resourceLevels ?? [:]).allSatisfy({ VillageMapMode.resourceFields.contains($0.key) && (0...3).contains($0.value) }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        return migrated
    }
    func save(_ state: VillageState) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(state), forKey: "village.v2.\(state.seed)")
    }
}
