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
        guard (2...VillageState.currentVersion).contains(state.version), state.seed == seed,
              (0...3).contains(state.weaponLevel),
              (state.buildingLevels ?? [:]).allSatisfy({ state.hasBuilding($0.key) && (1...GameProgression.maximumBuildingLevel).contains($0.value) }),
              (state.unitWeaponLevels ?? [:]).values.allSatisfy({ (0...VillageState.maximumWeaponLevel).contains($0) }),
              state.army?.isValid ?? true,
              state.coastalCampaign?.isValid ?? true,
              state.hasValidCommerce,
              state.resources.wood >= 0, state.resources.amber >= 0, state.resources.provisions >= 0,
              state.resources.wood <= 999_999, state.resources.amber <= 999_999, state.resources.provisions <= 999_999,
              (state.resourceLevels ?? [:]).allSatisfy({ VillageMapMode.resourceFields.contains($0.key) && (0...ResourceSiteKind.maximumLevel).contains($0.value) }),
              hasValidTiming(state),
              state.buildings[12] == .hall,
              state.buildings.allSatisfy({ (0..<25).contains($0.key) && ($0.value != .hall || $0.key == 12) }),
              (3...BotFaction.starting.count).contains(state.bots.count),
              state.bots.map(\.id) == Array(0..<state.bots.count),
              state.bots.allSatisfy({ $0.capital.isValid && $0.territory.count <= 64 && $0.territory.contains($0.capital) && $0.territory.allSatisfy(\.isValid) }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        var migrated = state
        if let job = state.construction {
            guard (0..<25).contains(job.plot), job.duration.isFinite, (1...86_400).contains(job.duration),
                  state.resourceUpgrade == nil, (1...GameProgression.maximumBuildingLevel).contains(job.level) else {
                throw CocoaError(.coderReadCorrupt)
            }
            if job.level == 1 {
                guard job.kind != .hall, state.buildings[job.plot] == nil,
                      state.version < 8 || !state.hasBuilding(job.kind),
                      job.paidCost == nil || job.paidCost == job.kind.cost else { throw CocoaError(.coderReadCorrupt) }
            } else {
                guard state.buildings[job.plot] == job.kind,
                      job.level == state.buildingLevel(job.kind) + 1,
                      job.paidCost == job.kind.cost(for: job.level) else { throw CocoaError(.coderReadCorrupt) }
            }
        }
        if let job = state.weaponUpgrade {
            guard state.hasBuilding(.forge), (1...VillageState.maximumWeaponLevel).contains(job.targetLevel),
                  job.endsAt.timeIntervalSince1970.isFinite else {
                throw CocoaError(.coderReadCorrupt)
            }
            if let unit = job.unit {
                guard state.unlockedUnits.contains(unit), job.targetLevel == state.weaponLevel(for: unit) + 1,
                      state.buildingLevel(.forge) >= job.targetLevel else { throw CocoaError(.coderReadCorrupt) }
            } else {
                guard job.targetLevel <= 3, job.targetLevel == state.weaponLevel + 1 else { throw CocoaError(.coderReadCorrupt) }
            }
        }
        if let job = state.resourceUpgrade {
            guard state.construction == nil,
                  let kind = ResourceSiteKind.at(job.plot),
                  (1...ResourceSiteKind.maximumLevel).contains(job.targetLevel),
                  job.targetLevel == state.resourceLevel(at: job.plot) + 1,
                  job.startedAt.timeIntervalSince1970.isFinite,
                  job.effectiveDuration.isFinite, (1...86_400).contains(job.effectiveDuration),
                  job.cost == (job.duration == nil ? kind.legacyCost(for: job.targetLevel) : kind.cost(for: job.targetLevel)) else {
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
        if let job = migrated.construction, state.version >= 8,
           !(job.kind == .hall && job.plot == 12 && job.level > 1),
           !VillageState.canPlace(job.kind, at: job.plot) {
            throw CocoaError(.coderReadCorrupt)
        }
        if migrated != state { try? save(migrated) }
        return migrated
    }
    func save(_ state: VillageState) throws {
        defaults.set(try JSONEncoder().encode(state), forKey: "village.v2.\(state.seed)")
        defaults.set(state.seed, forKey: "village.activeSeed")
    }

    func preserveUnreadableSave(seed: Int) throws {
        guard let data = defaults.data(forKey: "village.v2.\(seed)") else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        let backupKey = "village.unreadable.\(seed).\(UUID().uuidString)"
        defaults.set(data, forKey: backupKey)
        guard defaults.data(forKey: backupKey) == data else {
            throw CocoaError(.fileWriteUnknown)
        }
    }

    private func hasValidTiming(_ state: VillageState) -> Bool {
        // Validate before legacy production runs: arbitrary JSON dates can
        // overflow the integer seconds used by offline progression.
        let cooldownDates = state.army.map { Array($0.raidedUntil.values) } ?? []
        let dates = [state.lastProductionAt, state.lastBotExpansionAt,
                     state.construction?.startedAt, state.construction?.endsAt,
                     state.resourceUpgrade?.startedAt, state.resourceUpgrade?.endsAt,
                     state.weaponUpgrade?.endsAt, state.army?.training?.endsAt,
                     state.army?.research?.endsAt, state.army?.raid?.returnsAt].compactMap { $0 }
            + cooldownDates
        guard dates.allSatisfy({ $0 >= .distantPast && $0 <= .distantFuture }) else { return false }
        let remainder = state.productionRemainder ?? .zero
        return [remainder.wood, remainder.amber, remainder.provisions].allSatisfy {
            $0.isFinite && $0 >= 0 && $0 < 1
        }
    }
}
