import Foundation

extension DomainChecks {
    static func checkStorageValidation() throws {
        let suite = "StorageValidationChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults, backupAuthenticationKey: Data(repeating: 0x42, count: 32))
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
        var exported = restored
        exported.people = .nacre
        let bytes = try storage.exportBackup(exported, now: now)
        let before = defaults.data(forKey: "village.v2.42")
        let preview = try storage.previewBackup(bytes, now: now)
        precondition(preview.savedAt == now && preview.village.people == .nacre)
        precondition(preview.village.buildings == exported.buildings)
        precondition(defaults.data(forKey: "village.v2.42") == before, "Preview must not replace the local game")
        func rejectsTransfer(_ data: Data) throws {
            do { _ = try storage.previewBackup(data, now: now); preconditionFailure("Forged preview accepted") } catch { }
            for source in [VillageStorage.BackupSource.file, .iCloud] {
                do { _ = try storage.restoreBackup(data, now: now, source: source); preconditionFailure("Forged restore accepted") } catch { }
                precondition(defaults.data(forKey: "village.v2.42") == before, "Rejected transfer must preserve the live save")
            }
        }
        let envelope = try JSONSerialization.jsonObject(with: bytes) as! [String: Any]
        let payload = Data(base64Encoded: envelope["payload"] as! String)!
        var contents = try JSONSerialization.jsonObject(with: payload) as! [String: Any]
        var forgedVillage = contents["village"] as! [String: Any]
        var stocks = forgedVillage["resources"] as! [String: Any]
        stocks["wood"] = 999
        forgedVillage["resources"] = stocks
        contents["village"] = forgedVillage
        var forged = envelope
        forged["payload"] = try JSONSerialization.data(withJSONObject: contents).base64EncodedString()
        try rejectsTransfer(JSONSerialization.data(withJSONObject: forged))
        forged = envelope
        forged["authentication"] = Data(repeating: 0, count: 32).base64EncodedString()
        try rejectsTransfer(JSONSerialization.data(withJSONObject: forged))
        forged = envelope
        forged["keyID"] = "another-key"
        try rejectsTransfer(JSONSerialization.data(withJSONObject: forged))
        try rejectsTransfer(payload)
        contents["format"] = 1
        try rejectsTransfer(JSONSerialization.data(withJSONObject: contents))
        let wrongKey = VillageStorage(defaults: defaults, backupAuthenticationKey: Data(repeating: 0x13, count: 32))
        do { _ = try wrongKey.validateBackup(bytes, now: now); preconditionFailure("Wrong key accepted") } catch { }
        let otherDefaults = UserDefaults(suiteName: suite + ".receiver")!
        defer { otherDefaults.removePersistentDomain(forName: suite + ".receiver") }
        let receiver = VillageStorage(defaults: otherDefaults, backupAuthenticationKey: Data(repeating: 0x42, count: 32))
        let received = try receiver.validateBackup(bytes, now: now)
        precondition(received.people == .nacre)
        print("PASS: modified stocks, forged tags, altered key IDs, unsigned/legacy JSON and wrong keys rejected for both file and iCloud; shared-key transfer accepted")
        let invalidDate = try storage.exportBackup(exported, now: Date(timeIntervalSince1970: 1e100))
        do {
            _ = try storage.previewBackup(invalidDate, now: now)
            preconditionFailure("An invalid export date must not reach the restore review")
        } catch CocoaError.coderReadCorrupt {}
        print("PASS: read-only backup preview, preserved export date and invalid timestamp rejection")
        print("PASS: corrupt clocks, production fractions, legacy levels and construction jobs rejected without replacing saves")
    }
}
