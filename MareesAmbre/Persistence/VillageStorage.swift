import Foundation

struct VillageStorage {
    enum Scope { case standard, testing }
    enum BackupSource { case file, iCloud }
    var defaults: UserDefaults = .standard
    var scope: Scope = .standard

    private func key(_ name: String) -> String { scope == .testing ? "testMode." + name : name }
    var testingCopy: VillageStorage { VillageStorage(defaults: defaults, scope: .testing) }
    var hasSavedGame: Bool {
        guard defaults.object(forKey: key("village.activeSeed")) != nil else { return false }
        return defaults.data(forKey: key("village.v2.\(defaults.integer(forKey: key("village.activeSeed")))")) != nil
    }

    private struct Transfer: Codable {
        let format: Int
        let savedAt: Date
        let village: VillageState
    }

    func exportBackup(_ state: VillageState, now: Date = .now) throws -> Data {
        guard scope == .standard, state.progressionOrigin != .test else { throw CocoaError(.featureUnsupported) }
        return try JSONEncoder().encode(Transfer(format: 1, savedAt: now, village: state))
    }

    func validateBackup(_ data: Data, now: Date = .now) throws -> VillageState {
        guard data.count <= 8_000_000 else { throw CocoaError(.fileReadTooLarge) }
        let transfer = try JSONDecoder().decode(Transfer.self, from: data)
        guard scope == .standard, transfer.format == 1, transfer.village.progressionOrigin != .test else { throw CocoaError(.coderReadCorrupt) }
        // Run the complete existing migration and validation in isolated storage.
        // A rejected file must never modify the player's live defaults.
        let suite = "backup.validation.\(UUID().uuidString)"
        guard let isolated = UserDefaults(suiteName: suite) else { throw CocoaError(.fileReadUnknown) }
        defer { isolated.removePersistentDomain(forName: suite) }
        let temporary = VillageStorage(defaults: isolated)
        try temporary.save(transfer.village)
        guard let validated = try temporary.load(seed: transfer.village.seed,
            world: WorldMap(seed: transfer.village.seed), now: now), validated.people != nil else {
            throw CocoaError(.coderReadCorrupt)
        }
        return validated
    }

    func restoreBackup(_ data: Data, now: Date = .now, source: BackupSource = .file) throws -> VillageState {
        var validated = try validateBackup(data, now: now)
        if source == .file { validated.progressionOrigin = .importedFile }
        let encoded = try JSONEncoder().encode(validated)
        let active = activeSeed(now: now)
        for seed in Set([active, validated.seed]) {
            if let previous = defaults.data(forKey: key("village.v2.\(seed)")) {
                let recovery = key("village.beforeRestore.\(UUID().uuidString)")
                defaults.set(previous, forKey: recovery)
                guard defaults.data(forKey: recovery) == previous else { throw CocoaError(.fileWriteUnknown) }
            }
        }
        defaults.set(encoded, forKey: key("village.v2.\(validated.seed)"))
        defaults.set(validated.seed, forKey: key("village.activeSeed"))
        return validated
    }

    func activeSeed(now: Date = .now) -> Int {
        if defaults.object(forKey: key("village.activeSeed")) != nil {
            return defaults.integer(forKey: key("village.activeSeed"))
        }
        // Adopt the most recently played legacy village without deleting any save.
        let latest = defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(key("village.v2.")) }
            .compactMap { key -> VillageState? in
                guard let data = defaults.data(forKey: key) else { return nil }
                return try? JSONDecoder().decode(VillageState.self, from: data)
            }
            .max { ($0.lastProductionAt ?? .distantPast) < ($1.lastProductionAt ?? .distantPast) }
        let seed = latest?.seed ?? WeeklyChallenge.seed(for: now)
        defaults.set(seed, forKey: key("village.activeSeed"))
        return seed
    }

    func load(seed: Int, world: WorldMap, now: Date = .now) throws -> VillageState? {
        guard let data = defaults.data(forKey: key("village.v2.\(seed)")) else { return nil }
        let state = try JSONDecoder().decode(VillageState.self, from: data)
        guard scope == .testing || state.progressionOrigin != .test else { throw CocoaError(.coderReadCorrupt) }
        let all = [state] + (state.otherVillages ?? [])
        let heroRaids = all.filter { $0.army?.raid?.includesHero == true }
        guard heroRaids.count <= 1, heroRaids.isEmpty || (state.hero != nil && state.hero?.missions?.voyage == nil) else {
            throw CocoaError(.coderReadCorrupt)
        }
        guard all.count <= VillageState.maximumSettlements,
              Set(all.map(\.location)).count == all.count,
              all.filter({ $0.location == .home }).count == 1,
              (state.otherVillages ?? []).allSatisfy({ $0.otherVillages == nil && $0.beginnerProtection == nil && $0.hero == nil && $0.seed == seed && $0.people == state.people && $0.progressionOrigin == nil }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        if let voyage = state.hero?.missions?.voyage {
            guard all.contains(where: { $0.location == voyage.origin }),
                  voyage.startedAt >= (state.hero?.experienceStartedAt ?? .distantPast) else { throw CocoaError(.coderReadCorrupt) }
        }
        var migrated = try validateVillage(state, world: world, now: now)
        migrated.otherVillages = try state.otherVillages?.map { try validateVillage($0, world: world, now: now) }
        guard all.allSatisfy({ village in
            guard village.location.isValid, world.terrain(at: village.location) != .sea,
                  village.expansion?.isValid ?? true,
                  village.shipment?.isValid ?? true,
                  village.availableArmy.values.reduce(0, +) + (village.army?.training?.count ?? 0)
                    + (village.army?.raid?.units.values.reduce(0, +) ?? 0)
                    + (village.army?.convoy?.units.values.reduce(0, +) ?? 0) + village.foundingEscortCount + village.shipmentEscortCount <= ArmyState.maximumTroops else { return false }
            if village.location == .home { return village.settlementRole == nil && !village.isRefuge }
            return village.settlementRole != nil && village.expansion == nil
                && village.isRefuge == village.isRefugeSite(village.location)
                && (!village.isRefuge || village.coastalCampaign == nil)
        }), all.compactMap({ $0.expansion?.voyage }).count <= 1 else { throw CocoaError(.coderReadCorrupt) }
        guard all.indices.allSatisfy({ i in all.indices.allSatisfy { j in i == j || all[i].location.distance(to: all[j].location) >= 8 } }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        guard all.allSatisfy({ source in
            guard let shipment = source.shipment else { return true }
            guard shipment.destination != source.location, all.contains(where: { $0.location == shipment.destination }),
                  source.hasBuilding(.expeditionQuay),
                  shipment.arrivesAt.timeIntervalSince(shipment.departedAt) == source.shipmentDuration(to: shipment.destination),
                  shipment.returnsAt.timeIntervalSince(shipment.departedAt) == source.shipmentDuration(to: shipment.destination) * 2 else { return false }
            let clock = source.lastProductionAt ?? .distantPast
            return (!shipment.escortReturned || clock >= shipment.returnsAt)
                && (shipment.unloaded == Resources(wood: 0, amber: 0, provisions: 0) || clock >= shipment.arrivesAt)
        }) else { throw CocoaError(.coderReadCorrupt) }
        if let voyage = all.compactMap({ $0.expansion?.voyage }).first {
            guard all.count < VillageState.maximumSettlements,
                  world.terrain(at: voyage.destination) != .sea,
                  all.allSatisfy({ $0.location.distance(to: voyage.destination) >= 8 }),
                  voyage.isRefuge == state.isRefugeSite(voyage.destination) else { throw CocoaError(.coderReadCorrupt) }
        }
        if state.version < 19 { migrated.beginProtection(now: now) }
        if migrated != state { try? save(migrated) }
        return migrated
    }

    private func validateVillage(_ state: VillageState, world: WorldMap, now: Date) throws -> VillageState {
        guard (2...VillageState.currentVersion).contains(state.version), state.seed == world.seed,
              (0...3).contains(state.weaponLevel),
              (state.buildingLevels ?? [:]).allSatisfy({ state.hasBuilding($0.key) && (1...GameProgression.maximumBuildingLevel).contains($0.value) }),
              (state.unitWeaponLevels ?? [:]).values.allSatisfy({ (0...VillageState.maximumWeaponLevel).contains($0) }),
              (state.mailbox?.count ?? 0) <= VillageState.maximumMailPerVillage,
              Set((state.mailbox ?? []).map(\.id)).count == (state.mailbox?.count ?? 0),
              (state.mailbox ?? []).allSatisfy({ $0.isValid && $0.village == state.location }),
              state.nextBotAttackAt.map({ $0 >= .distantPast && $0 <= .distantFuture }) ?? true,
              state.beginnerProtection?.isValid ?? true,
              state.hero?.isValid ?? true,
              state.hero == nil || state.people != nil,
              state.beginnerProtection == nil || state.people != nil,
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
           !VillageState.canLoad(job.kind, at: job.plot) {
            throw CocoaError(.coderReadCorrupt)
        }
        return migrated
    }
    func save(_ state: VillageState) throws {
        guard scope == .testing || state.progressionOrigin != .test else { throw CocoaError(.featureUnsupported) }
        defaults.set(try JSONEncoder().encode(state), forKey: key("village.v2.\(state.seed)"))
        defaults.set(state.seed, forKey: key("village.activeSeed"))
    }

    func preserveUnreadableSave(seed: Int) throws {
        guard let data = defaults.data(forKey: key("village.v2.\(seed)")) else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        let backupKey = key("village.unreadable.\(seed).\(UUID().uuidString)")
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
