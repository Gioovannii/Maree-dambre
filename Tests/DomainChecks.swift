import Foundation

@main
struct DomainChecks {
    static func main() throws {
        let seed = 202639
        var game = GameState(seed: seed)
        precondition(game == GameState(seed: seed), "Same seed must produce same start")
        let initial = game
        precondition(!game.develop(2) && game == initial, "Cannot develop neutral islands")
        precondition(!game.develop(99) && game == initial, "Unknown IDs must not mutate state")
        precondition(game.develop(0))
        precondition(game.resources == Resources(wood: 60, amber: 25, provisions: 60))
        precondition(game.turn == 2 && game.islands[0].portLevel == 2)
        precondition(game.develop(0))
        let exhausted = game
        precondition(!game.develop(0) && game == exhausted, "Insufficient funds must be atomic")
        game.resources = Resources(wood: 1000, amber: 1000, provisions: 60)
        precondition(game.develop(0) && game.islands[0].portLevel == 4)
        precondition(!game.develop(0), "Port has a level cap")
        let data = try JSONEncoder().encode(game)
        let decoded = try JSONDecoder().decode(GameState.self, from: data)
        precondition(decoded == game, "Save round trip")
        let iso = ISO8601DateFormatter()
        precondition(WeeklyChallenge.seed(for: iso.date(from: "2026-09-21T00:00:00Z")!) == 202639)
        precondition(WeeklyChallenge.seed(for: iso.date(from: "2026-09-27T23:59:59Z")!) == 202639)
        precondition(WeeklyChallenge.seed(for: iso.date(from: "2026-09-28T00:00:00Z")!) == 202640)
        precondition(WeeklyChallenge.seed(for: iso.date(from: "2027-01-01T00:00:00Z")!) == 202653)
        let world = WorldMap(seed: seed)
        precondition(world.tiles.count == 40_000)
        precondition(world.tiles == WorldMap(seed: seed).tiles)
        precondition(world.tiles != WorldMap(seed: seed + 1).tiles)
        precondition(world.terrain(at: .home) != .sea)
        precondition(world.terrain(at: .init(x: -1, y: 0)) == .sea)
        var village = VillageState(seed: seed)
        precondition(VillageMapMode.resourceFields.slots.count == 10)
        precondition(VillageMapMode.townCenter.slots.count == 12)
        precondition(Set(VillageMapMode.resourceFields.slots).isDisjoint(with: VillageMapMode.townCenter.slots))
        precondition(!village.canBuild(.lumbermill, at: 0), "No building belongs on a resource terrain")
        precondition(village.canBuild(.lumbermill, at: 11))
        precondition(!village.canBuild(.hall, at: 11) && !village.canBuild(.farm, at: 12))
        precondition(ResourceSiteKind.at(0) == .woodland && ResourceSiteKind.at(2) == .cropland)
        precondition(ResourceSiteKind.at(4) == .amberVein && ResourceSiteKind.at(12) == nil)
        precondition(village.canDevelopResource(at: 0) && village.resourceLevel(at: 0) == 0)
        precondition(village.developResource(at: 0) && village.resourceLevel(at: 0) == 1)
        precondition(village.resources == Resources(wood: 55, amber: 30, provisions: 50))
        precondition(village.build(.lumbermill, at: 11))
        precondition(village.buildings[0] == nil && village.buildings[11] == .lumbermill)
        precondition(village.production == Resources(wood: 18, amber: 1, provisions: 2))
        precondition(village.canMoveBuilding(from: 11, to: 16))
        precondition(village.moveBuilding(from: 11, to: 16))
        precondition(!village.canMoveBuilding(from: 16, to: 0), "Buildings stay in the Centre-ville")
        precondition(!village.canMoveBuilding(from: 12, to: 13), "Town hall stays in place")
        let epoch = Date(timeIntervalSince1970: 1_800_000_000)
        let beforeOffline = village.resources
        village.lastProductionAt = epoch
        village.lastBotExpansionAt = epoch
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(1_800), on: world)
        precondition(village.resources == Resources(wood: beforeOffline.wood + 9,
                                                   amber: beforeOffline.amber,
                                                   provisions: beforeOffline.provisions + 1))
        precondition(village.productionRemainder == ProductionRemainder(wood: 0, amber: 0.5, provisions: 0))
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(3_600), on: world)
        precondition(village.resources == Resources(wood: beforeOffline.wood + 18,
                                                   amber: beforeOffline.amber + 1,
                                                   provisions: beforeOffline.provisions + 2))
        let snapshot = village
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(3_600), on: world)
        precondition(village == snapshot, "A repeated check cannot duplicate offline production")
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(6 * 3_600), on: world)
        precondition(village.bots.allSatisfy { $0.territory.count == 2 })
        village.resources = Resources(wood: 1_000, amber: 1_000, provisions: 1_000)
        precondition(village.developResource(at: 0) && village.developResource(at: 0))
        precondition(village.resourceLevel(at: 0) == 3 && !village.canDevelopResource(at: 0))
        let villageData = try JSONEncoder().encode(village)
        let restoredVillage = try JSONDecoder().decode(VillageState.self, from: villageData)
        precondition(restoredVillage == village)

        var oldSave = VillageState(seed: seed)
        oldSave.version = 6
        oldSave.resourceLevels = nil
        oldSave.buildings[0] = .lumbermill
        oldSave.buildings[2] = .farm
        let oldProduction = oldSave.production
        let oldData = try JSONEncoder().encode(oldSave)
        var restoredOldSave = try JSONDecoder().decode(VillageState.self, from: oldData)
        restoredOldSave.migrateIfNeeded(now: epoch)
        precondition(restoredOldSave.version == 7)
        precondition(restoredOldSave.buildings[0] == nil && restoredOldSave.buildings[2] == nil)
        precondition(restoredOldSave.resourceLevel(at: 0) == 1 && restoredOldSave.resourceLevel(at: 2) == 1)
        precondition(restoredOldSave.production == oldProduction, "Migration preserves hourly production")
        var legacyVillage = VillageState(seed: seed)
        legacyVillage.version = 4
        legacyVillage.resourceLevels = nil
        legacyVillage.buildings[13] = .farm
        legacyVillage.migrateIfNeeded(now: epoch)
        precondition(legacyVillage.version == 7 && legacyVillage.resourceLevel(at: 2) == 1)
        precondition(legacyVillage.buildings[12] == .hall && legacyVillage.buildings[13] == nil)

        var city = VillageState(seed: seed)
        precondition(city.build(.warehouse, at: 11) && city.storageCapacity == 800)
        precondition(city.build(.watchtower, at: 13) && city.automaticDefense == 2)
        var nacre = VillageState(seed: seed)
        nacre.people = .nacre
        precondition(nacre.automaticDefense == 1)
        precondition(nacre.build(.watchtower, at: 13) && nacre.automaticDefense == 3)
        print("PASS: 40,000 tiles, city-only buildings, resource sites, offline production and legacy migration")
        print("PASS: deterministic start, legal actions, costs, cap, serialization, UTC week boundaries")
    }
}
