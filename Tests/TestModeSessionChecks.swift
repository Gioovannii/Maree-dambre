import Foundation

extension SessionChecks {
    @MainActor
    static func checkIsolatedTestGame() throws {
        let suite = "MareesAmbre.TestMode.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults, backupAuthenticationKey: Data(repeating: 0x42, count: 32))
        let now = Date.now
        var initial = shipmentFixture(now: now)
        let hallLevel = initial.buildingLevel(.hall)
        initial.construction = ConstructionJob(plot: 12, kind: .hall, startedAt: now,
            duration: 3600, targetLevel: hallLevel + 1, paidCost: BuildingKind.hall.cost(for: hallLevel + 1))
        initial.beginProtection(now: now)
        initial.scheduleBotAttacks(now: now)
        try storage.save(initial)
        let normalBackup = try storage.exportBackup(initial)
        let session = VillageSession(storage: storage)
        let untouched = session.state
        session.advanceTestTime(by: 3600)
        precondition(session.state == untouched, "Normal play must reject acceleration even in a debug build")
        try session.startTestGame()
        precondition(session.isTestMode && session.hasSavedTestGame && session.state.progressionOrigin == .test)
        let normalBytes = defaults.data(forKey: "village.v2.42")!
        let normalSeed = defaults.integer(forKey: "village.activeSeed")
        let normalReminder = session.reminderAttackDate
        let activityStarts = ConstructionActivityController.starts
        let activityEnds = ConstructionActivityController.ends
        session.advanceTestTime(by: 3601)
        precondition(session.state.construction == nil && session.state.buildingLevel(.hall) == hallLevel + 1)
        precondition(defaults.data(forKey: "village.v2.42") == normalBytes,
            "Acceleration must not write any byte into the normal save")
        precondition(defaults.integer(forKey: "village.activeSeed") == normalSeed)
        precondition(session.reminderAttackDate == normalReminder,
            "Test dates must not replace normal notification deadlines")
        let simulated = session.state
        for interval in [Double.nan, Double.infinity, -1, 0, 86401] {
            session.advanceTestTime(by: interval)
            precondition(session.state == simulated)
        }
        let colony = session.state.otherVillages![0].location
        session.switchSettlement(to: colony)
        precondition(session.state.progressionOrigin == .test)
        precondition(session.state.otherVillages!.allSatisfy { $0.progressionOrigin == nil })
        do { _ = try session.exportBackup(); preconditionFailure("Test copies cannot be exported") } catch { }
        do { try session.restoreBackup(normalBackup); preconditionFailure("Restore cannot replace a normal save from test mode") } catch { }
        do { _ = try storage.exportBackup(session.state); preconditionFailure("Provenance must also block export at storage level") } catch { }
        precondition(defaults.data(forKey: "village.v2.42") == normalBytes)
        precondition(ConstructionActivityController.starts == activityStarts && ConstructionActivityController.ends == activityEnds,
            "Test actions must not start or stop normal construction Live Activities")
        let reopened = VillageSession(storage: storage)
        precondition(reopened.hasSavedTestGame)
        precondition(!reopened.isTestMode && reopened.state.progressionOrigin == nil,
            "An app restart must always open normal play")
        precondition(reopened.state.construction != nil && reopened.state.buildingLevel(.hall) == hallLevel)
        try session.leaveTestGame()
        precondition(!session.isTestMode && session.state.construction != nil)
        try session.resumeTestGame()
        precondition(session.isTestMode && session.state.location == colony)
        precondition(session.state.otherVillages!.first { $0.location == .home }!.buildingLevel(.hall) == hallLevel + 1)
        try session.leaveTestGame()
        try session.startTestGame()
        precondition(session.state.location == .home && session.state.construction != nil,
            "Creating a new copy must use normal progression, not the previous accelerated copy")
        try session.leaveTestGame()

        // Every file import carries unverified provenance, even after a round trip through iCloud.
        try session.restoreBackup(normalBackup)
        precondition(session.state.progressionOrigin == .importedFile)
        session.switchSettlement(to: colony)
        precondition(session.state.progressionOrigin == .importedFile)
        let transferred = try session.exportBackup()
        try session.restoreBackup(transferred, source: .iCloud)
        precondition(session.state.progressionOrigin == .importedFile)
        precondition(session.state.otherVillages!.allSatisfy { $0.progressionOrigin == nil })
        try session.restoreBackup(normalBackup, source: .iCloud)
        precondition(session.state.progressionOrigin == nil,
            "The iCloud restore path preserves the snapshot's provenance")
        var object = try JSONSerialization.jsonObject(with: normalBackup) as! [String: Any]
        let payload = Data(base64Encoded: object["payload"] as! String)!
        var contents = try JSONSerialization.jsonObject(with: payload) as! [String: Any]
        var village = contents["village"] as! [String: Any]
        village["progressionOrigin"] = "test"
        contents["village"] = village
        object["payload"] = try JSONSerialization.data(withJSONObject: contents).base64EncodedString()
        let testBackup = try JSONSerialization.data(withJSONObject: object)
        let beforeRejectedImport = session.state
        do { try session.restoreBackup(testBackup); preconditionFailure("Test provenance cannot enter normal play") } catch { }
        precondition(session.state == beforeRejectedImport)
        print("PASS: isolated test saves, normal bytes and reminders preserved, acceleration guards, relaunch, resume, switching, blocked exports and persistent file-import provenance")
    }
}
