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

    init(seed: Int) {
        version = 7
        self.seed = seed
        resources = Resources()
        buildings = [12: .hall]
        resourceLevels = [:]
        bots = BotFaction.starting
        people = nil
        lastProductionAt = .now
        productionRemainder = .zero
        lastBotExpansionAt = .now
    }

    mutating func migrateIfNeeded(now: Date = .now) {
        if version < 7 {
            var levels = resourceLevels ?? [:]
            for (plot, kind) in buildings.sorted(by: { $0.key < $1.key }) {
                let siteKind: ResourceSiteKind? = switch kind {
                case .lumbermill: .woodland
                case .farm: .cropland
                case .amberWorks: .amberVein
                case .hall, .watchtower, .warehouse: nil
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
        Self.canPlace(kind, at: plot) && buildings[plot] == nil
            && resources.wood >= kind.cost.wood && resources.amber >= kind.cost.amber
            && resources.provisions >= kind.cost.provisions
    }

    static func canPlace(_ kind: BuildingKind, at plot: Int) -> Bool {
        guard kind != .hall, kind.area.contains(plot), (0..<25).contains(plot) else { return false }
        return kind.suits(ground(at: plot))
    }

    func canMoveBuilding(from source: Int, to destination: Int) -> Bool {
        guard let kind = buildings[source], kind != .hall,
              buildings[destination] == nil,
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
        guard let kind = ResourceSiteKind.at(plot) else { return false }
        let nextLevel = resourceLevel(at: plot) + 1
        guard nextLevel <= 3 else { return false }
        let cost = kind.cost(for: nextLevel)
        return resources.wood >= cost.wood && resources.amber >= cost.amber
            && resources.provisions >= cost.provisions
    }

    @discardableResult
    mutating func developResource(at plot: Int) -> Bool {
        guard canDevelopResource(at: plot), let kind = ResourceSiteKind.at(plot) else { return false }
        let nextLevel = resourceLevel(at: plot) + 1
        let cost = kind.cost(for: nextLevel)
        resources.wood -= cost.wood
        resources.amber -= cost.amber
        resources.provisions -= cost.provisions
        var levels = resourceLevels ?? [:]
        levels[plot] = nextLevel
        resourceLevels = levels
        return true
    }

    @discardableResult
    mutating func build(_ kind: BuildingKind, at plot: Int) -> Bool {
        guard canBuild(kind, at: plot) else { return false }
        resources.wood -= kind.cost.wood
        resources.amber -= kind.cost.amber
        resources.provisions -= kind.cost.provisions
        buildings[plot] = kind
        return true
    }

    var production: Resources {
        var total = Resources(wood: 0, amber: 0, provisions: 0)
        for building in buildings.values {
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
        var remainder = productionRemainder ?? .zero
        if elapsed > 0 {
            let rates = production
            let wood = remainder.wood + Double(rates.wood) * elapsed / 3600
            let amber = remainder.amber + Double(rates.amber) * elapsed / 3600
            let provisions = remainder.provisions + Double(rates.provisions) * elapsed / 3600
            resources.wood = Self.adding(wood, to: resources.wood, capacity: storageCapacity)
            resources.amber = Self.adding(amber, to: resources.amber, capacity: storageCapacity)
            resources.provisions = Self.adding(provisions, to: resources.provisions, capacity: storageCapacity)
            remainder.wood = wood.truncatingRemainder(dividingBy: 1)
            remainder.amber = amber.truncatingRemainder(dividingBy: 1)
            remainder.provisions = provisions.truncatingRemainder(dividingBy: 1)
            lastProductionAt = now
            productionRemainder = remainder
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

    private static func adding(_ amount: Double, to stock: Int, capacity: Int) -> Int {
        let gain = min(Double(max(0, capacity - stock)), max(0, amount))
        return stock + Int(gain.rounded(.down))
    }
}
