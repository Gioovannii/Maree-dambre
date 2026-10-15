import Foundation

extension DomainChecks {
    static func checkCommerce() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let world = WorldMap(seed: 42)
        var start = VillageState(seed: 42)
        start.people = .sauniers
        start.buildings[10] = .market
        start.buildings[11] = .warCourt
        start.army = ArmyState(units: [.tideguard: 10, .pillager: 10], unlockedUnits: [.tideguard, .pillager])
        start.resources = Resources(wood: 300, amber: 300, provisions: 300)
        start.lastProductionAt = now
        start.lastBotExpansionAt = now
        precondition(!start.canSendConvoy(on: .sheltered, units: [.pillager: 1]))
        precondition(start.startCoastalCampaign())
        let invalidSelections: [[ArmyUnit: Int]] = [[:], [.pillager: -1], [.pillager: 11], [.pillager: Int.max], [.pillager: Int.min], [.tideMage: 1]]
        for selection in invalidSelections {
            var invalid = start
            precondition(!invalid.sendConvoy(on: .sheltered, units: selection) && invalid == start)
        }
        var missingMarket = start
        missingMarket.buildings[10] = nil
        precondition(!missingMarket.canSendConvoy(on: .sheltered, units: [.pillager: 1]))
        var poor = start
        poor.resources.wood = TradeRoute.cargoWood - 1
        precondition(!poor.canSendConvoy(on: .sheltered, units: [.pillager: 1]))

        var safe = start
        precondition(safe.sendConvoy(on: .sheltered, units: [.pillager: 1]))
        precondition(safe.resources == Resources(wood: 280, amber: 300, provisions: 295))
        precondition(safe.availableArmy[.pillager] == 9 && safe.army?.convoy?.returnsAtTide == 3)
        precondition(safe.army?.convoy?.isValid == true && safe.army?.isValid == true && safe.hasValidCommerce)
        precondition(!safe.sendConvoy(on: .crossing, units: [.pillager: 1]), "Only one commercial convoy can be active")
        let activeConvoy = safe.army?.convoy
        _ = safe.updateInRealTime(now: now.addingTimeInterval(30 * 86_400), on: world)
        precondition(safe.army?.convoy == activeConvoy && safe.coastalCampaign == start.coastalCampaign,
                     "Offline production cannot complete a convoy or advance an assault")
        precondition(safe.advanceCoastalTide() && safe.army?.convoy != nil)
        precondition(safe.advanceCoastalTide() && safe.army?.convoy != nil)
        precondition(safe.advanceCoastalTide() && safe.army?.convoy == nil)
        precondition(safe.commerce?.report?.successful == true && safe.commerce?.report?.lossCount == 0)
        precondition(safe.commerce?.report?.returnedCount == 1 && safe.commerce?.report?.pendingAmber == 18)
        let returned = safe.army
        safe.settleConvoy(at: 3)
        precondition(safe.army == returned, "Returning escorts cannot be duplicated")
        precondition(!safe.canClaimConvoyReward && !safe.claimConvoyReward(), "A full reserve keeps the payment pending")
        precondition(!safe.canSendConvoy(on: .crossing, units: [.pillager: 1]), "Cannot replace an unpaid report")
        safe.resources.amber = safe.storageCapacity - 18
        precondition(safe.claimConvoyReward() && safe.resources.amber == safe.storageCapacity)
        precondition(!safe.claimConvoyReward(), "Contract payment is credited exactly once")
        precondition(!safe.canSendConvoy(on: .sheltered, units: [.pillager: 1]), "The route needs six tides to restock")
        precondition(safe.canSendConvoy(on: .crossing, units: [.pillager: 1]), "Routes have independent finite offers")

        var weak = start
        let weakPreview = weak.convoyPreview(on: .crossing, units: [.pillager: 1])!
        precondition(!weakPreview.successful && weakPreview.lossCount == 1 && weakPreview.amberReward == 0)
        precondition(weak.sendConvoy(on: .crossing, units: [.pillager: 1]))
        precondition(weak.advanceCoastalTide() && weak.advanceCoastalTide())
        precondition(weak.commerce?.report == weakPreview && weak.army?.convoy == nil)
        precondition(!weak.claimConvoyReward() && weak.commerce?.report?.returnedCount == 0)

        var simultaneous = start
        simultaneous.army = ArmyState(units: [.tideguard: 4], unlockedUnits: [.tideguard])
        precondition(simultaneous.sendConvoy(on: .crossing, units: [.tideguard: 3]))
        precondition(simultaneous.convoyCapacity(for: [.tideguard: 3]) == 54)
        precondition(simultaneous.advanceCoastalTide() && simultaneous.advanceCoastalTide())
        precondition(simultaneous.coastalCampaign?.report?.garrisonPower == 10)
        precondition(simultaneous.coastalCampaign?.report?.won == false)
        precondition(simultaneous.availableArmy == [.tideguard: 3], "Escorts return after the battle, not before it")
        precondition(simultaneous.commerce?.report?.successful == true && simultaneous.commerce?.report?.pendingAmber == 26)
        precondition(simultaneous.army?.isValid == true && simultaneous.hasValidCommerce)

        for mage in [false, true] {
            var protected = start
            protected.army = ArmyState(units: [.amberSentry: 20, .tideMage: 1])
            let selection: [ArmyUnit: Int] = mage ? [.amberSentry: 20, .tideMage: 1] : [.amberSentry: 20]
            precondition(protected.sendConvoy(on: .crossing, units: selection))
            protected.buildings[14] = .infirmary
            protected.weaponsLevel = 3
            precondition(protected.advanceCoastalTide() && protected.advanceCoastalTide())
            precondition(protected.commerce?.report?.lossCount == (mage ? 3 : 4),
                         "Only deployed mages and support present at departure affect convoy losses")
            precondition(protected.commerce?.report?.order.attackUpgrade == 0)
        }
        var cap = start
        cap.army = ArmyState(units: [.tideguard: 99], unlockedUnits: [.tideguard])
        precondition(cap.sendConvoy(on: .sheltered, units: [.tideguard: 10]))
        precondition(!cap.canTrain(.tideguard, count: 2), "Escorts count towards the 100-unit cap")
        precondition(cap.train(.tideguard, count: 1, now: now))
        precondition(cap.raid(targetID: 0, units: [.tideguard: 89], now: now))
        precondition(cap.army?.isValid == true && cap.availableArmy.isEmpty)
        for _ in 0..<3 { precondition(cap.advanceCoastalTide()) }
        precondition(cap.availableArmy[.tideguard] == 10 && cap.army?.raid != nil && cap.army?.training != nil)
        precondition(cap.army?.isValid == true)

        let suite = "CommerceChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        var sailing = start
        precondition(sailing.sendConvoy(on: .crossing, units: [.tideguard: 3]))
        try storage.save(sailing)
        let restoredSailing = try storage.load(seed: 42, world: world, now: now)
        precondition(restoredSailing == sailing)
        try storage.save(safe)
        let restoredSafe = try storage.load(seed: 42, world: world, now: now)
        precondition(restoredSafe == safe)
        var legacy = start
        legacy.version = 12
        try storage.save(legacy)
        let migrated = try storage.load(seed: 42, world: world, now: now)!
        precondition(migrated.version == VillageState.currentVersion && migrated.commerce == nil && migrated.army?.convoy == nil)
        var corrupt = sailing
        corrupt.army?.convoy?.units = [.tideguard: Int.max]
        var corruptTide = sailing
        corruptTide.army?.convoy?.departedAtTide = Int.max
        var corruptStock = sailing
        corruptStock.commerce?.nextDepartureTide[.crossing] = Int.max
        var stale = sailing
        stale.coastalCampaign = simultaneous.coastalCampaign
        var orphan = sailing
        orphan.commerce = nil
        var futureReport = safe
        futureReport.commerce?.report?.order.departedAtTide = 20
        var missingOfferHistory = safe
        missingOfferHistory.commerce?.nextDepartureTide = [:]
        var paidFailure = weak
        paidFailure.commerce?.report?.rewardClaimed = true
        for invalid in [corrupt, corruptTide, corruptStock, stale, orphan, futureReport, missingOfferHistory, paidFailure] {
            try storage.save(invalid)
            do {
                _ = try storage.load(seed: 42, world: world, now: now)
                preconditionFailure("Invalid convoy or report accepted")
            } catch CocoaError.coderReadCorrupt {}
        }
        print("PASS: finite maritime offers, atomic cargo payment, capacity, separate escorts, route risks and same-tide battle ordering")
        print("PASS: convoy support snapshots, shared troop cap, offline pause, persisted payment, no duplicate rewards and corrupt-save rejection")
    }
}
