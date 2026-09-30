import Foundation

struct VillageStorage {
    var defaults: UserDefaults = .standard

    func activeSeed(now: Date = .now) -> Int {
        if defaults.object(forKey: "village.activeSeed") != nil {
            return defaults.integer(forKey: "village.activeSeed")
        }
        // Adopt the most recently played legacy village without deleting any save.
        let latest = defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("village.v2.") }
            .compactMap { key -> VillageState? in
                guard let data = defaults.data(forKey: key) else { return nil }
                return try? JSONDecoder().decode(VillageState.self, from: data)
            }
            .max { ($0.lastProductionAt ?? .distantPast) < ($1.lastProductionAt ?? .distantPast) }
        let seed = latest?.seed ?? WeeklyChallenge.seed(for: now)
        defaults.set(seed, forKey: "village.activeSeed")
        return seed
    }

    func load(seed: Int, world: WorldMap, now: Date = .now) throws -> VillageState? {
        guard let data = defaults.data(forKey: "village.v2.\(seed)") else { return nil }
        let state = try JSONDecoder().decode(VillageState.self, from: data)
        guard (2...9).contains(state.version), state.seed == seed,
              state.army?.isValid ?? true,
              state.resources.wood >= 0, state.resources.amber >= 0, state.resources.provisions >= 0,
              state.resources.wood <= 999_999, state.resources.amber <= 999_999, state.resources.provisions <= 999_999,
              state.buildings[12] == .hall,
              state.buildings.allSatisfy({ (0..<25).contains($0.key) && ($0.value != .hall || $0.key == 12) }),
              state.bots.map(\.id) == [0, 1, 2],
              state.bots.allSatisfy({ $0.capital.isValid && $0.territory.count <= 64 && $0.territory.contains($0.capital) && $0.territory.allSatisfy(\.isValid) }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        var migrated = state
        if let job = state.resourceUpgrade {
            guard state.construction == nil,
                  let kind = ResourceSiteKind.at(job.plot),
                  (1...ResourceSiteKind.maximumLevel).contains(job.targetLevel),
                  job.targetLevel == state.resourceLevel(at: job.plot) + 1,
                  job.startedAt.timeIntervalSince1970.isFinite,
                  job.cost == kind.cost(for: job.targetLevel) else {
                throw CocoaError(.coderReadCorrupt)
            }
        }
        if migrated.version < 8 {
            // Credit the old village's offline production before removing
            // duplicate buildings, so an existing save loses no earned stock.
            _ = migrated.updateInRealTime(now: now, on: world)
        }
        migrated.migrateIfNeeded(now: now)
        guard migrated.buildings.allSatisfy({ VillageState.canLoad($0.value, at: $0.key) || ($0.value == .hall && $0.key == 12) }),
              Set(migrated.buildings.values).count == migrated.buildings.count,
              (migrated.resourceLevels ?? [:]).allSatisfy({ VillageMapMode.resourceFields.contains($0.key) && (0...ResourceSiteKind.maximumLevel).contains($0.value) }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        if migrated != state { try? save(migrated) }
        return migrated
    }
    func save(_ state: VillageState) throws {
        defaults.set(try JSONEncoder().encode(state), forKey: "village.v2.\(state.seed)")
        defaults.set(state.seed, forKey: "village.activeSeed")
    }
}
