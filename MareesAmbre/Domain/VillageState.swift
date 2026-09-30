import Foundation

struct VillageState: Codable, Equatable {
    var version: Int
    let seed: Int
    var resources: Resources
    var buildings: [Int: BuildingKind]
    var resourceLevels: [Int: Int]?
    var bots: [BotFaction]
    var people: People?
    var lastProductionAt: Date?
    var productionRemainder: ProductionRemainder?
    var lastBotExpansionAt: Date?
    var construction: ConstructionJob?
    var resourceUpgrade: ResourceUpgrade?
    var army: ArmyState?

    private enum CodingKeys: String, CodingKey {
        case version, seed, resources, buildings, resourceLevels, bots, people
        case lastProductionAt, productionRemainder, lastBotExpansionAt, construction, army, resourceUpgrade
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decode(Int.self, forKey: .version)
        seed = try values.decode(Int.self, forKey: .seed)
        resources = try values.decode(Resources.self, forKey: .resources)
        buildings = try values.decode([Int: BuildingKind].self, forKey: .buildings)
        resourceLevels = try values.decodeIfPresent([Int: Int].self, forKey: .resourceLevels)
        bots = try values.decode([BotFaction].self, forKey: .bots)
        people = try values.decodeIfPresent(People.self, forKey: .people)
        lastProductionAt = try values.decodeIfPresent(Date.self, forKey: .lastProductionAt)
        productionRemainder = try values.decodeIfPresent(ProductionRemainder.self, forKey: .productionRemainder)
        lastBotExpansionAt = try values.decodeIfPresent(Date.self, forKey: .lastBotExpansionAt)
        construction = try values.decodeIfPresent(ConstructionJob.self, forKey: .construction)
        resourceUpgrade = try values.decodeIfPresent(ResourceUpgrade.self, forKey: .resourceUpgrade)
        army = try values.decodeIfPresent(ArmyState.self, forKey: .army)
    }

    init(seed: Int) {
        version = 9
        self.seed = seed
        resources = Resources()
        buildings = [12: .hall]
        resourceLevels = [:]
        bots = BotFaction.starting
        people = nil
        lastProductionAt = .now
        productionRemainder = .zero
        lastBotExpansionAt = .now
        construction = nil
    }

    mutating func migrateIfNeeded(now: Date = .now) {
        if version < 7 {
            var levels = resourceLevels ?? [:]
            for (plot, kind) in buildings.sorted(by: { $0.key < $1.key }) {
                let siteKind: ResourceSiteKind? = switch kind {
                case .lumbermill: .woodland
                case .farm: .cropland
                case .amberWorks: .amberVein
                case .hall, .watchtower, .warehouse, .warCourt, .academy: nil
                }
                guard let siteKind else { continue }
                let candidates = VillageMapMode.resourceFields.slots.filter { ResourceSiteKind.at($0) == siteKind }
                if let destination = candidates.min(by: { levels[$0, default: 0] < levels[$1, default: 0] }) {
                    levels[destination, default: 0] += 1
                    buildings.removeValue(forKey: plot)
                }
            }
            resourceLevels = levels
        }
        if version < 4 {
            let oldProductionDate = lastProductionAt
            lastProductionAt = oldProductionDate ?? now
            productionRemainder = .zero
            lastBotExpansionAt = oldProductionDate ?? now
            version = 4
        }
        if version < 5 {
            let previousBuildings = buildings
            var relocated: [Int: BuildingKind] = [12: .hall]
            for (oldPlot, kind) in previousBuildings.sorted(by: { $0.key < $1.key }) where kind != .hall {
                if Self.canPlace(kind, at: oldPlot), relocated[oldPlot] == nil {
                    relocated[oldPlot] = kind
                    continue
                }
                let newPlot = kind.area.slots.first { Self.canPlace(kind, at: $0) && relocated[$0] == nil }
                if let newPlot {
                    relocated[newPlot] = kind
                } else if (0..<25).contains(oldPlot), relocated[oldPlot] == nil {
                    // Preserve an unusually developed older save if its new district is full.
                    relocated[oldPlot] = kind
                }
            }
            buildings = relocated
            version = 5
        }
        if version < 6 {
            version = 6
        }
        if version < 7 {
            version = 7
        }
        if version < 8 {
            var seen = Set<BuildingKind>()
            for (plot, kind) in buildings.sorted(by: { $0.key < $1.key }) {
                if seen.insert(kind).inserted { continue }
                buildings.removeValue(forKey: plot)
                resources.wood = min(999_999, resources.wood + kind.cost.wood)
                resources.amber = min(999_999, resources.amber + kind.cost.amber)
                resources.provisions = min(999_999, resources.provisions + kind.cost.provisions)
            }
            version = 8
        }
        if version < 9 { version = 9 }
    }

    static func ground(at plot: Int) -> Terrain {
        switch plot {
        case 0, 1, 5: .forest
        case 4, 9: .amber
        case 20, 21, 24: .sea
        default: .meadow
        }
    }

    func canBuild(_ kind: BuildingKind, at plot: Int) -> Bool {
        Self.canPlace(kind, at: plot) && buildings[plot] == nil && !hasBuilding(kind)
            && construction == nil && resourceUpgrade == nil && meetsProductionRequirement(kind)
            && resources.wood >= kind.cost.wood && resources.amber >= kind.cost.amber
            && resources.provisions >= kind.cost.provisions
    }

    func hasBuilding(_ kind: BuildingKind) -> Bool { buildings.values.contains(kind) }

    func meetsProductionRequirement(_ kind: BuildingKind) -> Bool {
        guard let site = kind.requiredResourceSite else { return true }
        return VillageMapMode.resourceFields.slots.contains {
            ResourceSiteKind.at($0) == site && resourceLevel(at: $0) >= 10
        }
    }

    static func canPlace(_ kind: BuildingKind, at plot: Int) -> Bool {
        guard kind != .hall, kind.area.contains(plot), (0..<25).contains(plot) else { return false }
        return kind.suits(ground(at: plot))
    }

    func canMoveBuilding(from source: Int, to destination: Int) -> Bool {
        guard let kind = buildings[source], kind != .hall,
              buildings[destination] == nil,
              construction?.plot != destination,
              Self.canPlace(kind, at: destination) else { return false }
        return true
    }

    @discardableResult
    mutating func moveBuilding(from source: Int, to destination: Int) -> Bool {
        guard canMoveBuilding(from: source, to: destination),
              let kind = buildings.removeValue(forKey: source) else { return false }
        buildings[destination] = kind
        return true
    }

    static func canLoad(_ kind: BuildingKind, at plot: Int) -> Bool {
        canPlace(kind, at: plot)
    }

    func resourceLevel(at plot: Int) -> Int { resourceLevels?[plot] ?? 0 }

    func canDevelopResource(at plot: Int) -> Bool {
        guard construction == nil, resourceUpgrade == nil else { return false }
        guard let kind = ResourceSiteKind.at(plot) else { return false }
        let nextLevel = resourceLevel(at: plot) + 1
        guard nextLevel <= ResourceSiteKind.maximumLevel else { return false }
        let cost = kind.cost(for: nextLevel)
        return resources.wood >= cost.wood && resources.amber >= cost.amber
            && resources.provisions >= cost.provisions
    }

    @discardableResult
    mutating func developResource(at plot: Int, now: Date = .now) -> Bool {
        guard canDevelopResource(at: plot), let kind = ResourceSiteKind.at(plot) else { return false }
        let nextLevel = resourceLevel(at: plot) + 1
        let cost = kind.cost(for: nextLevel)
        resources.wood -= cost.wood
        resources.amber -= cost.amber
        resources.provisions -= cost.provisions
        resourceUpgrade = ResourceUpgrade(plot: plot, targetLevel: nextLevel, startedAt: now, cost: cost)
        return true
    }

    mutating func updateResourceUpgrade(now: Date = .now) {
        guard let job = resourceUpgrade, now >= job.endsAt else { return }
        var levels = resourceLevels ?? [:]
        levels[job.plot] = job.targetLevel
        resourceLevels = levels
        resourceUpgrade = nil
    }

    @discardableResult
    mutating func cancelResourceUpgrade(now: Date = .now) -> Bool {
        updateResourceUpgrade(now: now)
        guard let job = resourceUpgrade else { return false }
        resourceUpgrade = nil
        resources.wood = min(999_999, resources.wood + job.cost.wood / 2)
        resources.amber = min(999_999, resources.amber + job.cost.amber / 2)
        resources.provisions = min(999_999, resources.provisions + job.cost.provisions / 2)
        return true
    }

    @discardableResult
    mutating func build(_ kind: BuildingKind, at plot: Int, now: Date = .now) -> Bool {
        guard canBuild(kind, at: plot), construction == nil else { return false }
        resources.wood -= kind.cost.wood
        resources.amber -= kind.cost.amber
        resources.provisions -= kind.cost.provisions
        construction = ConstructionJob(plot: plot, kind: kind, startedAt: now, duration: 60)
        return true
    }

    mutating func updateConstruction(now: Date = .now) {
        guard let job = construction, now >= job.endsAt else { return }
        buildings[job.plot] = job.kind
        construction = nil
    }

    mutating func cancelConstruction(now: Date = .now) -> ConstructionJob? {
        updateConstruction(now: now)
        guard let job = construction else { return nil }
        construction = nil
        resources.wood = min(999_999, resources.wood + job.kind.cost.wood / 2)
        resources.amber = min(999_999, resources.amber + job.kind.cost.amber / 2)
        resources.provisions = min(999_999, resources.provisions + job.kind.cost.provisions / 2)
        return job
    }

    var production: Resources {
        var total = Resources(wood: 0, amber: 0, provisions: 0)
        for building in buildings.values {
            guard version < 7 || meetsProductionRequirement(building) else { continue }
            total.wood += building.yield.wood
            total.amber += building.yield.amber
            total.provisions += building.yield.provisions
        }
        for plot in VillageMapMode.resourceFields.slots {
            guard let kind = ResourceSiteKind.at(plot) else { continue }
            let yield = kind.yieldPerLevel
            let level = resourceLevel(at: plot)
            total.wood += yield.wood * level
            total.amber += yield.amber * level
            total.provisions += yield.provisions * level
        }
        return people?.adjustedProduction(total) ?? total
    }

    var storageCapacity: Int {
        300 + buildings.values.reduce(0) { $0 + $1.storageIncrease }
    }

    var automaticDefense: Int {
        buildings.values.reduce(0) { $0 + $1.defenseStrength } + (people?.baseDefenseBonus ?? 0)
    }

    mutating func updateInRealTime(now: Date = .now, on world: WorldMap) -> Int {
        guard world.seed == seed else { return 0 }
        let prior = lastProductionAt ?? now
        let elapsed = max(0, now.timeIntervalSince(prior))
        guard now >= prior else { return 0 }
        let events = [construction?.endsAt, resourceUpgrade?.endsAt, army?.raid?.returnsAt,
                      army?.training?.endsAt, army?.research?.endsAt]
            .compactMap { $0 }.filter { $0 <= now }
        for date in Set(events.map { max(prior, $0) } + [now]).sorted() {
            accrueProduction(until: date)
            updateConstruction(now: date)
            updateResourceUpgrade(now: date)
            updateArmy(now: date)
        }

        // Bot territory progresses on six-hour world intervals, including while the app is closed.
        let botDate = lastBotExpansionAt ?? now
        let intervals = max(0, Int(min(86_400_000, now.timeIntervalSince(botDate)) / (6 * 3600)))
        guard intervals > 0 else { return Int(elapsed) }
        lastBotExpansionAt = botDate.addingTimeInterval(Double(intervals * 6 * 3600))
        var occupied = Set(bots.flatMap(\.territory))
        occupied.insert(.home)
        for _ in 0..<intervals {
            for index in bots.indices {
                bots[index].level = min(10, bots[index].level + 1)
                guard bots[index].territory.count < 64 else { continue }
                let candidates = bots[index].territory.flatMap { tile in
                    [TileCoordinate(x: tile.x + 1, y: tile.y), TileCoordinate(x: tile.x, y: tile.y + 1),
                     TileCoordinate(x: tile.x - 1, y: tile.y), TileCoordinate(x: tile.x, y: tile.y - 1)]
                }
                if let next = candidates.first(where: { $0.isValid && world.terrain(at: $0) != .sea && !occupied.contains($0) }) {
                    bots[index].territory.append(next)
                    occupied.insert(next)
                }
            }
        }
        return Int(elapsed)
    }

    private mutating func accrueProduction(until now: Date) {
        let elapsed = max(0, now.timeIntervalSince(lastProductionAt ?? now))
        var remainder = productionRemainder ?? .zero
        if elapsed > 0 {
            let rates = production
            let wood = remainder.wood + Double(rates.wood) * elapsed / 3600
            let amber = remainder.amber + Double(rates.amber) * elapsed / 3600
            let provisions = remainder.provisions + Double(rates.provisions) * elapsed / 3600
            resources.wood = Self.adding(wood, to: resources.wood, capacity: storageCapacity)
            resources.amber = Self.adding(amber, to: resources.amber, capacity: storageCapacity)
            resources.provisions = Self.adding(provisions, to: resources.provisions, capacity: storageCapacity)
            remainder.wood = resources.wood >= storageCapacity ? 0 : max(0, wood - floor(wood + 1e-9))
            remainder.amber = resources.amber >= storageCapacity ? 0 : max(0, amber - floor(amber + 1e-9))
            remainder.provisions = resources.provisions >= storageCapacity ? 0 : max(0, provisions - floor(provisions + 1e-9))
            lastProductionAt = now
            productionRemainder = remainder
        }

    }

    private static func adding(_ amount: Double, to stock: Int, capacity: Int) -> Int {
        let gain = min(Double(max(0, capacity - stock)), max(0, amount))
        return stock + Int(floor(gain + 1e-9))
    }
}
