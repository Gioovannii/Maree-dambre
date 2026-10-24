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
        try checkAbsenceSummaryAfterRelaunch()
        try checkOfflineResume()
        try checkCompletedActionsAfterRelaunch()
        try checkSelectedRaidAfterRelaunch()
        try checkCoastalCampaignAfterRelaunch()
        try checkScheduledAttackAfterRelaunch()
        try checkHeroAfterRelaunch()
        try checkHeroMissionsAfterRelaunch()
        try checkHeroEquipmentAfterRelaunch()
        try checkConvoyAfterRelaunch()
        try checkFreshStart()
        try checkFoundingAfterRelaunch()
        try checkShipmentAfterRelaunch()
        try checkMailboxAfterRelaunch()
        try checkProtectionAfterRelaunch()
        print("PASS: unreadable and unsupported saves survive automatic ticks, scene changes and relaunch")
        print("PASS: explicit new game preserves the original bytes and resumes saving without duplicate backups")
        print("PASS: failed backup blocks replacement; fresh starts and offline upgrades still save normally")
        print("PASS: construction, research, training, weapons and raid resume together without duplicate loot")
        print("PASS: selected raid persists its garrison, accepts training and merges survivors after relaunch")
        print("PASS: coastal threat survives relaunch and offline ticks; defensive losses settle once through the actual session")
        print("PASS: convoys and escrow survive relaunch, return after defense, preserve full-storage payments and never duplicate troops or rewards")
    }

    @MainActor
    private static func checkAbsenceSummaryAfterRelaunch() throws {
        let suite = "MareesAmbre.AbsenceSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let now = Date.now
        var initial = shipmentFixture(now: now.addingTimeInterval(-3600))
        initial.beginProtection(now: now.addingTimeInterval(-3600))
        initial.army?.units = [.tideguard: 5]
        initial.army?.training = TrainingOrder(unit: .tideguard, count: 3, endsAt: now.addingTimeInterval(-1800))
        try storage.save(initial)
        let session = VillageSession(storage: storage)
        precondition(session.absenceSummary?.trainedUnits == 3)
        let summary = session.absenceSummary
        let unread = session.state.unreadMailCount
        session.refreshWorld(now: now.addingTimeInterval(1))
        precondition(session.absenceSummary == summary)
        session.dismissAbsenceSummary()
        precondition(session.absenceSummary == nil && session.state.unreadMailCount == unread)
        let reopened = VillageSession(storage: storage)
        precondition(reopened.absenceSummary == nil)
        precondition(reopened.state.army?.units[.tideguard] == 8)
        print("PASS: return summary appears once after offline load, survives ticks, dismisses without rewards or read changes, and does not repeat on relaunch")
    }

    @MainActor
    private static func checkProtectionAfterRelaunch() throws {
        let suite = "MareesAmbre.ProtectionSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var initial = shipmentFixture(now: .now)
        initial.beginProtection()
        let start = initial.beginnerProtection!.startedAt
        try storage.save(initial)
        let session = VillageSession(storage: storage)
        session.extendProtection()
        let deadline = start.addingTimeInterval(120 * 3600)
        precondition(session.state.beginnerProtection?.endsAt == deadline)
        session.switchSettlement(to: session.state.otherVillages![0].location)
        let reopened = VillageSession(storage: storage)
        precondition(!reopened.hasUnreadableSave)
        precondition(reopened.state.beginnerProtection?.extensionUsed == true)
        precondition(reopened.state.beginnerProtection?.endsAt == deadline)
        reopened.extendProtection()
        precondition(reopened.state.beginnerProtection?.endsAt == deadline)
        precondition(reopened.state.otherVillages!.allSatisfy { $0.beginnerProtection == nil })
        print("PASS: domain-wide protection and single extension persist through the actual session, switching and relaunch")
    }

    @MainActor
    private static func checkMailboxAfterRelaunch() throws {
        let suite = "MareesAmbre.MailSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var initial = shipmentFixture(now: .now)
        initial.receiveMail(.welcome, key: "welcome", at: .now)
        initial.otherVillages![0].receiveMail(.welcome, key: "welcome", at: .now)
        let colonyMail = initial.otherVillages![0].mailbox![0]
        try storage.save(initial)
        let session = VillageSession(storage: storage)
        precondition(session.state.unreadMailCount == 2)
        session.markMailRead(colonyMail.id)
        let reopened = VillageSession(storage: storage)
        precondition(reopened.state.unreadMailCount == 1)
        precondition(reopened.state.allMail.first { $0.id == colonyMail.id }!.isRead)
        reopened.switchSettlement(to: colonyMail.village)
        reopened.markAllMailRead()
        let restored = VillageSession(storage: storage)
        precondition(restored.state.unreadMailCount == 0 && restored.state.allMail.count == 2)
        print("PASS: actual mailbox read status, mark-all-read and global inbox survive village switching and relaunch")
    }

    @MainActor
    private static func checkShipmentAfterRelaunch() throws {
        let suite = "MareesAmbre.ShipmentSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let initial = shipmentFixture(now: .now)
        let target = initial.otherVillages![0].location
        try storage.save(initial)
        let session = VillageSession(storage: storage)
        precondition(session.sendShipment(to: target, cargo: Resources(wood: 40, amber: 20, provisions: 30), units: [.tideguard: 5]))
        let returns = session.state.shipment!.returnsAt
        let reopened = VillageSession(storage: storage)
        precondition(!reopened.hasUnreadableSave && reopened.state.shipmentEscortCount == 5)
        reopened.switchSettlement(to: target)
        reopened.refreshWorld(now: returns)
        let restored = VillageSession(storage: storage)
        precondition(!restored.hasUnreadableSave && restored.state.location == target)
        precondition(restored.state.resources.wood >= 40 && restored.state.resources.amber >= 20 && restored.state.resources.provisions >= 30)
        let capital = restored.state.otherVillages!.first { $0.location == .home }!
        precondition(capital.availableArmy[.tideguard] == 100 && capital.shipment!.isComplete)
        let settled = restored.state
        restored.refreshWorld(now: returns)
        precondition(restored.state == settled)
        print("PASS: actual session shipment, switching during transit, offline cargo delivery, escort return and relaunch without duplication")
    }

    @MainActor
    private static func checkFoundingAfterRelaunch() throws {
        let suite = "MareesAmbre.FoundingSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var village = VillageState(seed: 42)
        village.people = .sauniers
        for kind in [BuildingKind.academy, .warehouse, .expeditionQuay] {
            let plot = VillageMapMode.townCenter.slots.first { village.buildings[$0] == nil && VillageState.canPlace(kind, at: $0) }!
            village.buildings[plot] = kind
        }
        village.buildingLevels = [.hall: 5, .academy: 3, .warehouse: 3, .expeditionQuay: 2]
        village.resources = Resources(wood: 1800, amber: 1600, provisions: 1800)
        village.army = ArmyState(units: [.tideguard: 10], unlockedUnits: [.tideguard])
        village.expansion = ExpansionProgress(researched: true, settlersReady: true)
        try storage.save(village)
        let session = VillageSession(storage: storage)
        let site = session.state.suggestedSettlementSites(on: session.world).last!
        precondition(session.foundColony(at: site, role: .production, escort: .tideguard))
        let arrival = session.state.expansion!.voyage!.arrivesAt
        let reopened = VillageSession(storage: storage)
        precondition(reopened.state.expansion?.voyage?.destination == site)
        reopened.refreshWorld(now: arrival)
        precondition(reopened.state.settlementCount == 2)
        reopened.switchSettlement(to: site)
        let selected = VillageSession(storage: storage)
        precondition(selected.state.location == site && selected.state.settlementCount == 2)
        precondition(!selected.hasUnreadableSave && selected.state.isRefuge)
        precondition(selected.state.otherVillages?.first?.availableArmy[.tideguard] == 5)
        selected.refreshWorld(now: arrival.addingTimeInterval(3600))
        precondition(selected.state.settlementCount == 2)
        print("PASS: actual session founding, offline arrival, selected colony persistence and separate capital garrison")
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
    private static func checkHeroEquipmentAfterRelaunch() throws {
        let suite = "MareesAmbre.HeroEquipmentSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let now = Date.now.addingTimeInterval(-1)
        var state = shipmentFixture(now: now)
        precondition(state.customizeHero(portrait: .captainWoman, name: "Élyne", now: now))
        state.hero?.experience = 100
        state.hero?.missions = HeroMissions(chapter: 3, materials: 20)
        try storage.save(state)
        let session = VillageSession(storage: storage)
        precondition(session.upgradeHeroEquipment(.spyglass))
        precondition(session.upgradeHeroEquipment(.outfit))
        precondition(session.state.hero?.missions?.materials == 11)
        precondition(session.startHeroMission(.surveyCoast))
        let voyage = session.state.hero!.missions!.voyage!
        precondition(!session.upgradeHeroEquipment(.sail))
        session.switchSettlement(to: state.otherVillages![0].location)
        let reopened = VillageSession(storage: storage)
        precondition(reopened.state.hero?.missions?.equipment == HeroEquipment(spyglass: 1, outfit: 1, sail: 0))
        reopened.refreshWorld(now: voyage.endsAt)
        precondition(reopened.state.hero?.totalExperience == 122 && reopened.state.hero?.missions?.materials == 13)
        let final = VillageSession(storage: storage)
        precondition(final.state.hero?.totalExperience == 122 && final.state.hero?.missions?.materials == 13)
        print("PASS: actual session equipment purchases persist and apply once to missions after switching and relaunch")
    }

    @MainActor
    private static func checkHeroMissionsAfterRelaunch() throws {
        let suite = "MareesAmbre.HeroVoyageSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let departure = Date.now.addingTimeInterval(-1200)
        var state = shipmentFixture(now: departure)
        precondition(state.customizeHero(portrait: .captainWoman, name: "Élyne", now: departure))
        precondition(state.startHeroMission(.discoverWreck, now: departure))
        try storage.save(state)
        let session = VillageSession(storage: storage)
        precondition(session.state.hero?.totalExperience == 30 && session.state.hero?.missions?.chapter == 1)
        precondition(session.startHeroMission(.recoverBoat))
        let voyage = session.state.hero!.missions!.voyage!
        precondition(!session.startHeroMission(.recoverBoat))
        session.switchSettlement(to: state.otherVillages![0].location)
        let reopened = VillageSession(storage: storage)
        precondition(reopened.state.hero?.missions?.voyage == voyage)
        reopened.refreshWorld(now: voyage.endsAt)
        precondition(reopened.state.hero?.totalExperience == 80 && reopened.state.hero?.missions?.materials == 5)
        let again = VillageSession(storage: storage)
        precondition(again.state.hero?.totalExperience == 80 && again.state.hero?.missions?.voyage == nil)
        print("PASS: actual session completes offline hero voyages, launches once, switches villages and persists rewards")
    }

    @MainActor
    private static func checkHeroAfterRelaunch() throws {
        let suite = "MareesAmbre.HeroSession.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        let state = shipmentFixture(now: .now)
        try storage.save(state)
        let session = VillageSession(storage: storage)
        precondition(session.customizeHero(portrait: .captainWoman, name: "Élyne"))
        session.switchSettlement(to: state.otherVillages![0].location)
        let restored = VillageSession(storage: storage)
        precondition(!restored.hasUnreadableSave && restored.state.hero?.name == "Élyne")
        precondition(restored.customizeHero(portrait: .captainMan, name: "Maël"))
        restored.switchSettlement(to: .home)
        let capital = VillageSession(storage: storage)
        precondition(capital.state.hero?.portrait == .captainMan && capital.state.hero?.name == "Maël")
        precondition(capital.raid(0, units: [.tideguard: 5], withHero: true))
        precondition(capital.state.army?.raid?.includesHero == true)
        capital.refreshWorld(now: .now.addingTimeInterval(3600))
        precondition(capital.state.hero?.totalExperience == 20)
        let returned = VillageSession(storage: storage)
        precondition(returned.state.hero?.totalExperience == 20)
        returned.refreshWorld(now: capital.state.lastProductionAt!)
        precondition(returned.state.hero?.totalExperience == 20)
        print("PASS: actual session saves hero customization, combat XP and daily limits across relaunch and village changes")
    }

    @MainActor
    private static func checkScheduledAttackAfterRelaunch() throws {
        let suite = "MareesAmbre.ScheduledSessionChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var state = VillageState(seed: 42)
        state.people = .sauniers
        try storage.save(state)
        let session = VillageSession(storage: storage)
        let due = session.state.nextBotAttackAt!
        let reopened = VillageSession(storage: storage)
        precondition(reopened.state.nextBotAttackAt == due)
        let returnDate = RaidRestPolicy.attackDate(for: due.addingTimeInterval(14 * 86_400))
        reopened.refreshWorld(now: returnDate)
        precondition(reopened.state.coastalCampaign?.assaultsResolved == 1)
        precondition(reopened.state.nextBotAttackAt == RaidRestPolicy.attackDate(for: returnDate.addingTimeInterval(86_400)))
        let restored = VillageSession(storage: storage)
        precondition(!restored.hasUnreadableSave)
        precondition(restored.state.coastalCampaign?.assaultsResolved == 1)
        precondition(restored.state.nextBotAttackAt == reopened.state.nextBotAttackAt)
        restored.refreshWorld(now: returnDate)
        precondition(restored.state.coastalCampaign?.assaultsResolved == 1)
        print("PASS: actual session schedules, resolves one offline assault, saves report and preserves deadline after relaunch")
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
        relaunched.refreshWorld(now: .now.addingTimeInterval(3600))
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
        relaunched.refreshWorld(now: .now.addingTimeInterval(3600))
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
