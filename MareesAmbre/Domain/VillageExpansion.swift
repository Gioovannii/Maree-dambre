import Foundation

extension VillageState {
    static let maximumSettlements = 3
    static let navigationCost = Resources(wood: 300, amber: 250, provisions: 300)
    static let settlersCost = Resources(wood: 400, amber: 150, provisions: 500)
    static let navigationDuration: TimeInterval = 1_800
    static let settlersDuration: TimeInterval = 3_600

    var location: TileCoordinate { settlementLocation ?? .home }
    var isRefuge: Bool { settlementRefuge ?? false }
    var settlementName: String {
        settlementRole?.name ?? String(localized: "screen.world.amber_harbor", defaultValue: "Port d’Ambre")
    }
    var settlementCount: Int { 1 + (otherVillages?.count ?? 0) }
    var foundingEscortCount: Int { expansion?.voyage == nil ? 0 : FoundingVoyage.escortCount }
    var ownedLocations: [TileCoordinate] { [location] + (otherVillages ?? []).map(\.location) }
    var pendingFoundingLocations: [TileCoordinate] {
        ([self] + (otherVillages ?? [])).compactMap { $0.expansion?.voyage?.destination }
    }
    var foundationCost: Resources {
        settlementCount < 2 ? Resources(wood: 1_800, amber: 1_200, provisions: 1_500)
            : Resources(wood: 3_600, amber: 2_400, provisions: 3_000)
    }
    var expansionRequirementsMet: Bool {
        location == .home && people != nil && settlementCount < Self.maximumSettlements
            && buildingLevel(.hall) >= (settlementCount < 2 ? 5 : 8)
            && buildingLevel(.academy) >= (settlementCount < 2 ? 3 : 5)
            && buildingLevel(.expeditionQuay) >= (settlementCount < 2 ? 2 : 3)
            && buildingLevel(.warehouse) >= (settlementCount < 2 ? 3 : 7)
    }
    func canAffordExpansion(_ cost: Resources) -> Bool {
        resources.wood >= cost.wood && resources.amber >= cost.amber && resources.provisions >= cost.provisions
    }
    var canResearchNavigation: Bool {
        expansionRequirementsMet && expansion?.researched != true && expansion?.researchEndsAt == nil
            && canAffordExpansion(Self.navigationCost)
    }
    var canPrepareSettlers: Bool {
        expansionRequirementsMet && expansion?.researched == true && expansion?.settlersReady != true
            && expansion?.settlersEndAt == nil && expansion?.voyage == nil && canAffordExpansion(Self.settlersCost)
    }
    private mutating func payExpansion(_ cost: Resources) {
        resources.wood -= cost.wood; resources.amber -= cost.amber; resources.provisions -= cost.provisions
    }
    @discardableResult
    mutating func researchNavigation(now: Date = .now) -> Bool {
        guard canResearchNavigation else { return false }
        payExpansion(Self.navigationCost)
        var progress = expansion ?? ExpansionProgress()
        progress.researchEndsAt = now.addingTimeInterval(Self.navigationDuration)
        expansion = progress
        return true
    }
    @discardableResult
    mutating func prepareSettlers(now: Date = .now) -> Bool {
        guard canPrepareSettlers else { return false }
        payExpansion(Self.settlersCost)
        expansion?.settlersEndAt = now.addingTimeInterval(Self.settlersDuration)
        return true
    }
    func isRefugeSite(_ tile: TileCoordinate) -> Bool {
        // A fixed geographic rule, independent of subsequent bot expansion.
        BotFaction.starting.allSatisfy { tile.distance(to: $0.capital) >= 35 }
    }
    func canSettle(at tile: TileCoordinate, on world: WorldMap) -> Bool {
        guard tile.isValid, world.seed == seed, world.terrain(at: tile) != .sea,
              ownedLocations.allSatisfy({ tile.distance(to: $0) >= 8 }),
              !pendingFoundingLocations.contains(tile) else { return false }
        return bots.allSatisfy { bot in
            bot.territory.allSatisfy { tile.distance(to: $0) >= 6 }
        }
    }
    func foundingDuration(to tile: TileCoordinate) -> TimeInterval {
        1_800 + TimeInterval(location.distance(to: tile) * 30)
    }
    func canFound(at tile: TileCoordinate, escort: ArmyUnit, on world: WorldMap) -> Bool {
        expansionRequirementsMet && expansion?.settlersReady == true && expansion?.voyage == nil
            && canSettle(at: tile, on: world) && canAffordExpansion(foundationCost)
            && availableArmy[escort, default: 0] >= FoundingVoyage.escortCount
    }
    @discardableResult
    mutating func found(at tile: TileCoordinate, role: SettlementRole, escort: ArmyUnit,
                        on world: WorldMap, now: Date = .now) -> Bool {
        guard canFound(at: tile, escort: escort, on: world) else { return false }
        payExpansion(foundationCost)
        let researchedUnits = unlockedUnits
        army?.unlockedUnits = researchedUnits
        army?.units[escort, default: 0] -= FoundingVoyage.escortCount
        expansion?.settlersReady = false
        let voyage = FoundingVoyage(destination: tile, role: role, isRefuge: isRefugeSite(tile),
                                         escort: escort, arrivesAt: now.addingTimeInterval(foundingDuration(to: tile)))
        expansion?.voyage = voyage
        return true
    }
    /// Advances all local economies and the shared map, then settles arrival once.
    mutating func updateDomain(now: Date = .now, on world: WorldMap) {
        guard world.seed == seed, now >= (lastProductionAt ?? now) else { return }
        initializeHeroProgression(now: now)
        let prior = lastProductionAt ?? now
        let villages = [self] + (otherVillages ?? [])
        let events = villages.flatMap { village -> [Date] in
            var dates = [village.construction?.endsAt].compactMap { $0 }
            if let shipment = village.shipment, !shipment.isComplete {
                dates += [shipment.arrivesAt, shipment.returnsAt]
            }
            return dates.filter { $0 <= now }.map { max(prior, $0) }
        }
        for date in Set(events + [now]).sorted() {
            advanceDomain(now: date, on: world)
            settleShipments(now: date)
        }
        resolveScheduledAttacks(now: now)
        notifyProtectionExpiry(now: now)
        settleHeroMission(now: now)
        awardHeroExperience()
    }

    private mutating func advanceDomain(now: Date, on world: WorldMap) {
        let protected = ownedLocations + pendingFoundingLocations
        _ = updateInRealTime(now: now, on: world, protectedLocations: protected)
        var others = otherVillages ?? []
        for index in others.indices {
            others[index].bots = bots
            _ = others[index].updateInRealTime(now: now, on: world, protectedLocations: protected, advanceBots: false)
            others[index].lastBotExpansionAt = lastBotExpansionAt
        }
        otherVillages = others.isEmpty ? nil : others
        var arrivals: [VillageState] = []
        if let colony = settleExpansion(now: now, on: world, count: settlementCount) { arrivals.append(colony) }
        others = otherVillages ?? []
        for index in others.indices {
            if let colony = others[index].settleExpansion(now: now, on: world, count: settlementCount + arrivals.count) {
                arrivals.append(colony)
            }
        }
        otherVillages = others + arrivals
        if otherVillages?.isEmpty == true { otherVillages = nil }
    }

    private mutating func settleExpansion(now: Date, on world: WorldMap, count: Int) -> VillageState? {
        if let end = expansion?.researchEndsAt, now >= end {
            expansion?.researched = true
            expansion?.researchEndsAt = nil
        }
        if let end = expansion?.settlersEndAt, now >= end {
            expansion?.settlersReady = true
            expansion?.settlersEndAt = nil
        }
        guard let voyage = expansion?.voyage, now >= voyage.arrivesAt, count < Self.maximumSettlements else { return nil }
        var colony = VillageState(seed: seed)
        colony.people = people
        if nextBotAttackAt != nil && !voyage.isRefuge { colony.nextBotAttackAt = RaidRestPolicy.attackDate(for: max(now, beginnerProtection?.endsAt ?? now).addingTimeInterval(Self.botAttackInterval)) }
        colony.settlementLocation = voyage.destination
        colony.settlementRole = voyage.role
        colony.settlementRefuge = voyage.isRefuge
        colony.resources = Resources(wood: 200, amber: 100, provisions: 200)
        colony.resourceLevels = [0: 1, 2: 1, 4: 1]
        colony.army = ArmyState(units: [voyage.escort: FoundingVoyage.escortCount], unlockedUnits: [voyage.escort])
        colony.lastProductionAt = voyage.arrivesAt
        colony.lastBotExpansionAt = now
        colony.bots = bots
        _ = colony.updateInRealTime(now: now, on: world, advanceBots: false)
        receiveMail(.colony(voyage), key: "colony.\(voyage.destination.x).\(voyage.destination.y)", at: voyage.arrivesAt)
        expansion?.voyage = nil
        return colony
    }
    @discardableResult
    mutating func switchSettlement(to destination: TileCoordinate) -> Bool {
        guard var others = otherVillages, let index = others.firstIndex(where: { $0.location == destination }) else { return false }
        var next = others.remove(at: index)
        var current = self
        current.otherVillages = nil
        current.beginnerProtection = nil
        current.hero = nil
        current.progressionOrigin = nil
        others.append(current)
        next.otherVillages = others
        next.beginnerProtection = beginnerProtection
        next.hero = hero
        next.progressionOrigin = progressionOrigin
        next.bots = bots
        self = next
        return true
    }
    /// Stable, accessible alternatives to tapping individual map tiles.
    func suggestedSettlementSites(on world: WorldMap) -> [TileCoordinate] {
        var sites: [TileCoordinate] = []
        for anchor in [TileCoordinate(x: 120, y: 108), TileCoordinate(x: 25, y: 25), TileCoordinate(x: 175, y: 175)] {
            let candidates = (0..<12).flatMap { dy in (0..<12).map { dx in TileCoordinate(x: anchor.x + dx, y: anchor.y + dy) } }
            if let tile = candidates.first(where: { canSettle(at: $0, on: world) }) { sites.append(tile) }
        }
        return sites
    }
}
