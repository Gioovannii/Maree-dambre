import Foundation

func checkExpansion() throws {
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
    var corrupt = restored
    corrupt.otherVillages![0].otherVillages = [VillageState(seed: 42)]
    try storage.save(corrupt)
    do {
        _ = try storage.load(seed: 42, world: world)
        preconditionFailure("Nested domains must be rejected")
    } catch { }
    print("PASS: founding prerequisites, costs, escort capacity, refuge, offline arrival, separate economies, switching, three-settlement cap and save validation")
}
