import Foundation

extension DomainChecks {
    static func checkStorageValidation() throws {
        let suite = "StorageValidationChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let world = WorldMap(seed: 42)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var valid = VillageState(seed: 42)
        valid.lastProductionAt = now
        valid.lastBotExpansionAt = now
        valid.construction = ConstructionJob(plot: 10, kind: .academy, startedAt: now, duration: 60)

        func rejects(_ state: VillageState, _ reason: String) throws {
            let original = try JSONEncoder().encode(state)
            defaults.set(original, forKey: "village.v2.42")
            do {
                _ = try storage.load(seed: 42, world: world, now: now)
                preconditionFailure("Invalid save accepted: \(reason)")
            } catch CocoaError.coderReadCorrupt {}
            precondition(defaults.data(forKey: "village.v2.42") == original, "Validation must preserve the rejected save")
        }

        var corrupt = valid
        corrupt.lastProductionAt = Date(timeIntervalSince1970: -1e100)
        try rejects(corrupt, "production date would overflow integer elapsed seconds")
        corrupt = valid
        corrupt.lastBotExpansionAt = Date(timeIntervalSince1970: 1e100)
        try rejects(corrupt, "invalid bot clock")
        corrupt = valid
        corrupt.productionRemainder = ProductionRemainder(wood: 1e100, amber: 0, provisions: 0)
        try rejects(corrupt, "fractional production cannot be a whole stock")
        corrupt = valid
        corrupt.productionRemainder = ProductionRemainder(wood: 0, amber: -0.1, provisions: 0)
        try rejects(corrupt, "negative production remainder")
        corrupt = valid
        corrupt.version = 6
        corrupt.resourceLevels = [0: Int.max]
        try rejects(corrupt, "legacy production must be validated before migration")
        for job in [
            ConstructionJob(plot: 12, kind: .academy, startedAt: now, duration: 60),
            ConstructionJob(plot: 10, kind: .hall, startedAt: now, duration: 60),
            ConstructionJob(plot: 25, kind: .academy, startedAt: now, duration: 60),
            ConstructionJob(plot: 0, kind: .academy, startedAt: now, duration: 60),
            ConstructionJob(plot: 10, kind: .academy, startedAt: now, duration: 0),
            ConstructionJob(plot: 10, kind: .academy, startedAt: now, duration: -60),
            ConstructionJob(plot: 10, kind: .academy, startedAt: now, duration: 1e100)
        ] {
            corrupt = valid
            corrupt.construction = job
            try rejects(corrupt, "invalid construction placement or duration")
        }
        corrupt = valid
        corrupt.buildings[11] = .academy
        try rejects(corrupt, "construction would duplicate a unique building")
        corrupt = valid
        corrupt.army = ArmyState(training: TrainingOrder(unit: .tideguard, count: 1, endsAt: Date(timeIntervalSince1970: 1e100)))
        try rejects(corrupt, "unbounded army timer")

        try storage.save(valid)
        var restored = try storage.load(seed: 42, world: world, now: now)!
        _ = restored.updateInRealTime(now: now.addingTimeInterval(120), on: world)
        precondition(restored.buildings[10] == .academy && restored.buildings[12] == .hall)
        precondition(restored.construction == nil)
        print("PASS: corrupt clocks, production fractions, legacy levels and construction jobs rejected without replacing saves")
    }
}
