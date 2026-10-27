import Foundation

func checkExpansion() throws {
    checkDomainObjectives()
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var capital = VillageState(seed: 42)
    capital.people = .sauniers
    capital.lastProductionAt = now
    capital.lastBotExpansionAt = now
    for kind in [BuildingKind.academy, .warehouse, .expeditionQuay, .warCourt] {
        let plot = VillageMapMode.townCenter.slots.first { capital.buildings[$0] == nil && VillageState.canPlace(kind, at: $0) }!
        capital.buildings[plot] = kind
    }
    capital.buildingLevels = [.hall: 5, .academy: 3, .warehouse: 3, .expeditionQuay: 2]
    capital.resources = Resources(wood: 1800, amber: 1800, provisions: 1800)
    capital.army = ArmyState(units: [.tideguard: 100], unlockedUnits: [.tideguard])
    precondition(capital.foundationCost.wood <= capital.storageCapacity)
    precondition(capital.researchNavigation(now: now))
    let research = capital
    precondition(!capital.researchNavigation(now: now) && capital == research)
    precondition(!capital.prepareSettlers(now: now))
    capital.updateDomain(now: now.addingTimeInterval(VillageState.navigationDuration), on: world)
    precondition(capital.expansion?.researched == true)
    precondition(capital.prepareSettlers(now: now.addingTimeInterval(VillageState.navigationDuration)))
    let readyAt = capital.expansion!.settlersEndAt!
    capital.updateDomain(now: readyAt, on: world)
    precondition(capital.expansion?.settlersReady == true)
    capital.resources = Resources(wood: 1800, amber: 1800, provisions: 1800)
    let site = capital.suggestedSettlementSites(on: world).last!
    precondition(capital.isRefugeSite(site))
    precondition(!capital.canSettle(at: .home, on: world))
    precondition(!capital.canSettle(at: capital.bots[0].capital, on: world))
    let sea = (0..<200).flatMap { y in (0..<200).map { TileCoordinate(x: $0, y: y) } }.first { world.terrain(at: $0) == .sea }!
    precondition(!capital.canSettle(at: sea, on: world))
    let before = capital
    precondition(!capital.found(at: sea, role: .production, escort: .tideguard, on: world, now: readyAt) && capital == before)
    precondition(capital.found(at: site, role: .production, escort: .tideguard, on: world, now: readyAt))
    precondition(capital.resources == Resources(wood: 0, amber: 600, provisions: 300))
    precondition(capital.availableArmy[.tideguard] == 95 && capital.foundingEscortCount == 5)
    capital.resources = Resources(wood: 1800, amber: 1800, provisions: 1800)
    precondition(!capital.canTrain(.tideguard, count: 5), "Founding escorts still reserve the shared army capacity")
    let arrival = capital.expansion!.voyage!.arrivesAt
    capital.updateDomain(now: arrival.addingTimeInterval(-1), on: world)
    precondition(capital.settlementCount == 1)
    let suite = "MareesAmbre.Expansion.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(capital)
    var restored = try storage.load(seed: 42, world: world, now: arrival.addingTimeInterval(-1))!
    restored.updateDomain(now: arrival, on: world)
    precondition(restored.settlementCount == 2 && restored.expansion?.voyage == nil)
    precondition(restored.allMail.filter { if case .colony = $0.content { true } else { false } }.count == 1)
    precondition(restored.otherVillages![0].resources == Resources(wood: 200, amber: 100, provisions: 200))
    restored.updateDomain(now: arrival, on: world)
    precondition(restored.settlementCount == 2, "Arrival must settle exactly once")
    let capitalStock = restored.resources
    precondition(restored.switchSettlement(to: site))
    precondition(restored.location == site && restored.isRefuge && restored.settlementRole == .production)
    precondition(restored.availableArmy[.tideguard] == 5)
    precondition(!restored.canStartCoastalCampaign && !restored.advanceCoastalTide())
    precondition(!restored.canResearchNavigation)
    precondition(restored.developResource(at: 0, now: arrival))
    let colonyJob = restored.resourceUpgrade!
    restored.updateDomain(now: colonyJob.endsAt, on: world)
    precondition(restored.resourceLevel(at: 0) == 2)
    precondition(restored.switchSettlement(to: .home))
    precondition(restored.resourceLevel(at: 0) == 0 && restored.resources.wood >= capitalStock.wood)
    precondition(restored.otherVillages![0].resourceLevel(at: 0) == 2)
    restored.buildingLevels = [.hall: 8, .academy: 5, .warehouse: 7, .expeditionQuay: 3]
    restored.resources = Resources(wood: 3800, amber: 3800, provisions: 3800)
    precondition(restored.foundationCost == Resources(wood: 3600, amber: 2400, provisions: 3000))
    precondition(restored.foundationCost.wood <= restored.storageCapacity)
    precondition(restored.prepareSettlers(now: colonyJob.endsAt))
    let crewAt = restored.expansion!.settlersEndAt!
    precondition(restored.switchSettlement(to: site))
    restored.updateDomain(now: crewAt, on: world)
    precondition(restored.switchSettlement(to: .home))
    precondition(restored.expansion?.settlersReady == true, "Inactive capital queues must advance")
    restored.resources = Resources(wood: 3800, amber: 3800, provisions: 3800)
    let secondSite = restored.suggestedSettlementSites(on: world).first!
    precondition(restored.found(at: secondSite, role: .commerce, escort: .tideguard, on: world, now: crewAt))
    let secondArrival = restored.expansion!.voyage!.arrivesAt
    precondition(restored.switchSettlement(to: site))
    try storage.save(restored)
    restored = try storage.load(seed: 42, world: world, now: crewAt)!
    restored.updateDomain(now: secondArrival.addingTimeInterval(3600), on: world)
    precondition(restored.settlementCount == 3, "Founding must complete while another village is selected")
    precondition(restored.otherVillages!.first { $0.location == secondSite }!.resources.wood > 200)
    precondition(restored.switchSettlement(to: .home))
    precondition(!restored.canPrepareSettlers && !restored.expansionRequirementsMet)
    try storage.save(restored)
    let finalSave = try storage.load(seed: 42, world: world, now: secondArrival)
    precondition(finalSave == restored)
    try checkLighthouseJourney(from: restored, now: secondArrival.addingTimeInterval(3600))
    var corrupt = restored
    corrupt.otherVillages![0].otherVillages = [VillageState(seed: 42)]
    try storage.save(corrupt)
    do {
        _ = try storage.load(seed: 42, world: world)
        preconditionFailure("Nested domains must be rejected")
    } catch { }
    print("PASS: founding prerequisites, costs, escort capacity, refuge, offline arrival, separate economies, switching, three-settlement cap and save validation")
}

private func checkDomainObjectives() {
    precondition(VillageState(seed: 42).nextDomainObjective == nil)
    var state = shipmentFixture(now: .now)
    state.otherVillages![0].resourceLevels = [:]
    precondition(state.nextDomainObjective?.kind == .colony)
    for plot in [0, 2, 4] { state.otherVillages![0].resourceLevels![plot] = 3 }
    precondition(state.nextDomainObjective?.kind == .forge)
    state.buildings[14] = .forge
    state.buildingLevels = [.forge: 3]
    precondition(state.nextDomainObjective?.kind == .capital)
    state.buildings[10] = .academy
    state.buildings[23] = .expeditionQuay
    state.buildings[16] = .warehouse
    state.buildingLevels = [.forge: 3, .hall: 8, .academy: 5, .warehouse: 7, .expeditionQuay: 3]
    precondition(state.nextDomainObjective?.kind == .thirdVillage)
    let expected = state.nextDomainObjective
    let colony = state.otherVillages![0].location
    precondition(state.switchSettlement(to: colony))
    precondition(state.nextDomainObjective == expected, "The objective follows the domain when switching villages")
    var third = VillageState(seed: state.seed)
    third.settlementLocation = TileCoordinate(x: 1, y: 1)
    state.otherVillages!.append(third)
    precondition(state.nextDomainObjective?.kind == .established)
    print("PASS: post-colony goals, live progress, capital requirements, third settlement and domain-wide navigation targets")
}

private func checkLighthouseJourney(from initial: VillageState, now: Date) throws {
    var state = initial
    var clock = now
    state.scheduleBotAttacks(now: now)
    let world = WorldMap(seed: state.seed)
    let colony = state.otherVillages![0].location
    let suite = "LighthouseChecks.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    var locked = shipmentFixture(now: now)
    locked.resources = Resources(wood: 5300, amber: 5300, provisions: 5300)
    precondition(!locked.startLighthouseStage(now: now), "Three villages are required")
    state.buildingLevels?[.warehouse] = 1
    state.resources = locked.resources
    precondition(!state.canStartLighthouseStage, "Storage must contain the full stage price")
    state.buildingLevels?[.warehouse] = 10
    for stage in LighthouseStage.allCases {
        precondition(state.lighthouseProgress.stage == stage)
        precondition(max(stage.cost.wood, stage.cost.amber, stage.cost.provisions) <= state.storageCapacity)
        state.resources = stage.cost
        let colonyStocks = state.otherVillages!.map(\.resources)
        precondition(state.startLighthouseStage(now: clock))
        precondition(state.resources == Resources(wood: 0, amber: 0, provisions: 0))
        precondition(state.otherVillages!.map(\.resources) == colonyStocks, "Only the capital pays")
        precondition(!state.startLighthouseStage(now: clock), "A running stage cannot charge twice")
        let end = state.lighthouse!.finishesAt!
        try storage.save(state)
        state = try storage.load(seed: state.seed, world: world, now: clock)!
        precondition(state.switchSettlement(to: colony))
        precondition(!state.canStartLighthouseStage, "The worksite belongs to the capital")
        state.updateDomain(now: end.addingTimeInterval(-1), on: world)
        precondition(state.lighthouseProgress.completedStages == stage.rawValue)
        state.updateDomain(now: end, on: world)
        precondition(state.lighthouseProgress.completedStages == stage.rawValue + 1)
        state.updateDomain(now: end, on: world)
        precondition(state.lighthouseProgress.completedStages == stage.rawValue + 1)
        precondition(state.switchSettlement(to: .home))
        clock = end
    }
    precondition(state.lighthouseProgress.isComplete && state.lighthouse?.completedAt == clock)
    state.scheduleBotAttacks(now: clock)
    precondition(state.nextDomainBotAttackDate == nil && !state.canStartLighthouseStage)
    state.resolveScheduledAttacks(now: clock.addingTimeInterval(30 * 86400))
    precondition(state.nextDomainBotAttackDate == nil)
    try storage.save(state)
    let restored = try storage.load(seed: state.seed, world: world, now: clock)!
    precondition(restored.lighthouse == state.lighthouse)
    var corrupt = state
    corrupt.lighthouse?.completedStages = 6
    try storage.save(corrupt)
    do { _ = try storage.load(seed: state.seed, world: world, now: clock); preconditionFailure("Invalid lighthouse accepted") }
    catch CocoaError.coderReadCorrupt { }
    print("PASS: five lighthouse stages, capital-only payment, storage limits, persistent work, inactive-capital completion, no duplicate charges, victory and post-victory raid peace")
}
