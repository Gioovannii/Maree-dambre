import Foundation

@main
struct SessionChecks {
    @MainActor
    static func main() async throws {
        try await checkUnreadableSave(Data("{invalid save}".utf8))
        var futureSave = VillageState(seed: 42)
        futureSave.version = VillageState.currentVersion + 1
        try await checkUnreadableSave(JSONEncoder().encode(futureSave))
        var invalidClock = VillageState(seed: 42)
        invalidClock.lastProductionAt = Date(timeIntervalSince1970: -1e100)
        try await checkUnreadableSave(JSONEncoder().encode(invalidClock))
        try checkBackupFailure()
        try checkOfflineResume()
        try checkCompletedActionsAfterRelaunch()
        try checkSelectedRaidAfterRelaunch()
        try checkCoastalCampaignAfterRelaunch()
        try checkConvoyAfterRelaunch()
        try checkFreshStart()
        print("PASS: unreadable and unsupported saves survive automatic ticks, scene changes and relaunch")
        print("PASS: explicit new game preserves the original bytes and resumes saving without duplicate backups")
        print("PASS: failed backup blocks replacement; fresh starts and offline upgrades still save normally")
        print("PASS: construction, research, training, weapons and raid resume together without duplicate loot")
        print("PASS: selected raid persists its garrison, accepts training and merges survivors after relaunch")
        print("PASS: coastal threat survives relaunch and offline ticks; defensive losses settle once through the actual session")
        print("PASS: convoys and escrow survive relaunch, return after defense, preserve full-storage payments and never duplicate troops or rewards")
    }

    @MainActor
    private static func checkUnreadableSave(_ original: Data) async throws {
        let suite = "MareesAmbre.SessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        defaults.set(42, forKey: "village.activeSeed")
        defaults.set(original, forKey: "village.v2.42")
        let session = VillageSession(storage: storage)
        let initial = session.state
        precondition(session.hasUnreadableSave && session.saveRecoveryMessage != nil)
        // Exercise the actual production task as well as foreground/background refreshes.
        try await Task.sleep(for: .milliseconds(1_100))
        session.refreshWorld(now: .now.addingTimeInterval(3_600))
        session.refreshAfterSceneChange()
        precondition(defaults.data(forKey: "village.v2.42") == original)
        precondition(session.state == initial, "An unreadable save must not progress a fallback game")
        let relaunched = VillageSession(storage: storage)
        precondition(relaunched.hasUnreadableSave)
        precondition(defaults.data(forKey: "village.v2.42") == original)
        session.choosePeople(.sauniers)
        precondition(!session.hasUnreadableSave && session.saveRecoveryMessage == nil)
        precondition(session.state.resources == VillageState(seed: 42).resources)
        let backups = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("village.unreadable.42.") }
        precondition(backups.count == 1 && defaults.data(forKey: backups[0]) == original)
        session.choosePeople(.nacre)
        session.refreshWorld(now: .now.addingTimeInterval(3_600))
        let restored = try storage.load(seed: 42, world: WorldMap(seed: 42))
        precondition(restored?.people == .sauniers)
        precondition(restored?.lastProductionAt == session.state.lastProductionAt)
        precondition(defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("village.unreadable.") }.count == 1)
    }

    @MainActor
    private static func checkBackupFailure() throws {
        let suite = "MareesAmbre.SessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(42, forKey: "village.activeSeed")
        let original = Data("broken".utf8)
        defaults.set(original, forKey: "village.v2.42")
        let session = VillageSession(storage: VillageStorage(defaults: defaults))
        defaults.removeObject(forKey: "village.v2.42")
        session.choosePeople(.sauniers)
        precondition(session.hasUnreadableSave && session.state.people == nil)
        precondition(session.saveRecoveryMessage != nil)
        precondition(defaults.data(forKey: "village.v2.42") == nil, "No new save if the original cannot be backed up")
        defaults.set(original, forKey: "village.v2.42")
        session.choosePeople(.sauniers)
        precondition(!session.hasUnreadableSave && session.state.people == .sauniers)
    }

    @MainActor
    private static func checkOfflineResume() throws {
        let suite = "MareesAmbre.SessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let departure = Date.now.addingTimeInterval(-120)
        var state = VillageState(seed: 202639)
        state.people = .sauniers
        state.lastProductionAt = departure
        precondition(state.developResource(at: 0, now: departure))
        try storage.save(state)
        defaults.removeObject(forKey: "village.activeSeed")
        let session = VillageSession(storage: storage)
        precondition(!session.hasUnreadableSave && session.state.seed == state.seed)
        precondition(session.state.resourceUpgrade == nil && session.state.resourceLevel(at: 0) == 1)
        let reloaded = VillageSession(storage: storage)
        precondition(reloaded.state.resourceLevel(at: 0) == 1 && reloaded.state.people == .sauniers)
        precondition(defaults.dictionaryRepresentation().keys.allSatisfy { !$0.hasPrefix("village.unreadable.") })
    }

    @MainActor
    private static func checkCompletedActionsAfterRelaunch() throws {
        let suite = "MareesAmbre.SessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let departure = Date.now.addingTimeInterval(-130)
        var state = VillageState(seed: 42)
        state.people = .sauniers
        state.lastProductionAt = departure
        state.lastBotExpansionAt = departure
        state.buildings = [12: .hall, 10: .academy, 11: .warCourt, 13: .forge, 16: .warehouse]
        state.resources = Resources(wood: 800, amber: 800, provisions: 800)
        state.army = ArmyState(units: [.tideguard: 3], unlockedUnits: [.tideguard])
        precondition(state.build(.market, at: 14, now: departure))
        precondition(state.research(.pillager, now: departure))
        precondition(state.train(.tideguard, count: 2, now: departure))
        precondition(state.upgradeWeapons(for: .tideguard, now: departure))
        precondition(state.raid(targetID: 0, now: departure))
        try storage.save(state)

        let session = VillageSession(storage: storage)
        precondition(!session.hasUnreadableSave)
        precondition(session.state.hasBuilding(.market) && session.state.construction == nil)
        precondition(session.state.unlockedUnits.contains(.pillager) && session.state.army?.research == nil)
        precondition(session.state.availableArmy[.tideguard] == 5 && session.state.army?.training == nil)
        precondition(session.state.weaponLevel(for: .tideguard) == 1 && session.state.weaponUpgrade == nil)
        precondition(session.state.army?.raid == nil && session.state.army?.report != nil)
        precondition(session.state.army?.raidedUntil[0] == departure.addingTimeInterval(720))
        let stocks = session.state.resources
        let army = session.state.army
        let relaunched = VillageSession(storage: storage)
        relaunched.refreshAfterSceneChange()
        precondition(relaunched.state.resources == stocks && relaunched.state.army == army)
        precondition(relaunched.state.hasBuilding(.market) && relaunched.state.weaponLevel(for: .tideguard) == 1)
    }

    @MainActor
    private static func checkSelectedRaidAfterRelaunch() throws {
        let suite = "MareesAmbre.SessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var state = VillageState(seed: 42)
        state.people = .sauniers
        state.buildings[11] = .warCourt
        state.army = ArmyState(units: [.tideguard: 10], unlockedUnits: [.tideguard])
        try storage.save(state)
        let session = VillageSession(storage: storage)
        precondition(session.raid(0, units: [.tideguard: 2]))
        precondition(session.state.availableArmy[.tideguard] == 8)
        precondition(session.state.army?.raid?.units == [.tideguard: 2])
        let relaunched = VillageSession(storage: storage)
        precondition(relaunched.state.availableArmy[.tideguard] == 8)
        precondition(relaunched.state.army?.raid == session.state.army?.raid)
        precondition(!relaunched.raid(1, units: [.tideguard: 2]))
        relaunched.train(.tideguard, count: 2)
        precondition(relaunched.state.army?.training?.count == 2)
        let returnDate = relaunched.state.army!.raid!.returnsAt.addingTimeInterval(1)
        relaunched.refreshWorld(now: returnDate)
        precondition(relaunched.state.availableArmy[.tideguard] == 12)
        precondition(relaunched.state.army?.raid == nil && relaunched.state.army?.training == nil)
        let stocks = relaunched.state.resources
        let restored = VillageSession(storage: storage)
        precondition(restored.state.availableArmy[.tideguard] == 12 && restored.state.resources == stocks)
    }

    @MainActor
    private static func checkCoastalCampaignAfterRelaunch() throws {
        let suite = "MareesAmbre.CoastalSessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var state = VillageState(seed: 42)
        state.people = .sauniers
        state.buildings[10] = .warCourt
        state.army = ArmyState(units: [.tideguard: 2], unlockedUnits: [.tideguard])
        try storage.save(state)
        let session = VillageSession(storage: storage)
        precondition(session.startCoastalCampaign() && session.advanceCoastalTide())
        let threatened = session.state.coastalCampaign
        let relaunched = VillageSession(storage: storage)
        precondition(relaunched.state.coastalCampaign == threatened)
        relaunched.refreshWorld(now: .now.addingTimeInterval(14 * 86_400))
        precondition(relaunched.state.coastalCampaign == threatened)
        let preview = relaunched.state.defensePreview
        precondition(relaunched.advanceCoastalTide())
        precondition(relaunched.state.coastalCampaign?.report == preview)
        precondition(relaunched.state.availableArmy[.tideguard] == 1)
        let settled = relaunched.state
        let restored = VillageSession(storage: storage)
        precondition(restored.state.coastalCampaign == settled.coastalCampaign && restored.state.army == settled.army)
        precondition(restored.state.resources == settled.resources)
        precondition(!restored.startCoastalCampaign(), "The session cannot restart a campaign to reset its threat")
    }

    @MainActor
    private static func checkConvoyAfterRelaunch() throws {
        let suite = "MareesAmbre.ConvoySessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var state = VillageState(seed: 42)
        state.people = .sauniers
        state.buildings[10] = .market
        state.buildings[11] = .warCourt
        state.buildings[13] = .forge
        state.resources = Resources(wood: 300, amber: 300, provisions: 300)
        state.army = ArmyState(units: [.tideguard: 4, .pillager: 2], unlockedUnits: [.tideguard, .pillager])
        try storage.save(state)
        let session = VillageSession(storage: storage)
        precondition(session.startCoastalCampaign())
        precondition(session.sendConvoy(on: .crossing, units: [.tideguard: 3]))
        let active = session.state.army?.convoy
        let relaunched = VillageSession(storage: storage)
        precondition(relaunched.state.army?.convoy == active && relaunched.state.availableArmy[.tideguard] == 1)
        relaunched.refreshWorld(now: .now.addingTimeInterval(7 * 86_400))
        precondition(relaunched.state.army?.convoy == active && relaunched.state.coastalCampaign?.tide == 0)
        precondition(relaunched.advanceCoastalTide() && relaunched.advanceCoastalTide())
        precondition(relaunched.state.army?.convoy == nil && relaunched.state.commerce?.report?.pendingAmber == 26)
        precondition(relaunched.state.availableArmy[.tideguard] == 3 && relaunched.state.availableArmy[.pillager] == 1)
        precondition(!relaunched.claimConvoyReward(), "No silent overflow into a full amber reserve")
        let awaitingPayment = VillageSession(storage: storage)
        precondition(awaitingPayment.state.commerce?.report?.pendingAmber == 26)
        awaitingPayment.upgradeWeapons(for: .tideguard)
        precondition(awaitingPayment.state.weaponUpgrade != nil)
        precondition(awaitingPayment.claimConvoyReward() && awaitingPayment.state.resources.amber == 298)
        let settled = awaitingPayment.state
        let restored = VillageSession(storage: storage)
        precondition(restored.state.army == settled.army && restored.state.commerce == settled.commerce)
        precondition(restored.state.resources == settled.resources && !restored.claimConvoyReward())
    }

    @MainActor
    private static func checkFreshStart() throws {
        let suite = "MareesAmbre.SessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let session = VillageSession(storage: storage)
        precondition(!session.hasUnreadableSave && session.state.people == nil)
        session.choosePeople(.nacre)
        let reloaded = VillageSession(storage: storage)
        precondition(reloaded.state.seed == session.state.seed && reloaded.state.people == .nacre)
    }
}
