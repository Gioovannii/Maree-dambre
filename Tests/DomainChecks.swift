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
        precondition(VillageMapMode.resourceFields.slots.count + VillageMapMode.townCenter.slots.count == 22)
        precondition(village.canBuild(.lumbermill, at: 0) && !village.canBuild(.lumbermill, at: 2))
        precondition(village.canBuild(.farm, at: 2) && village.canBuild(.amberWorks, at: 4))
        let newVillage = village
        precondition(!village.build(.farm, at: 20) && village == newVillage)
        precondition(!village.build(.hall, at: 11) && village == newVillage)
        precondition(!village.build(.farm, at: 12) && village == newVillage)
        precondition(!village.build(.farm, at: -1) && village == newVillage)
        precondition(!village.build(.lumbermill, at: 11) && village == newVillage)
        precondition(village.build(.lumbermill, at: 0))
        precondition(village.resources == Resources(wood: 55, amber: 30, provisions: 50))
        let afterBuild = village
        precondition(!village.build(.farm, at: 0) && village == afterBuild)
        let epoch = Date(timeIntervalSince1970: 1_800_000_000)
        village.lastProductionAt = epoch
        village.lastBotExpansionAt = epoch
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(1_800), on: world)
        precondition(village.resources == Resources(wood: 60, amber: 30, provisions: 51))
        precondition(village.productionRemainder == ProductionRemainder(wood: 0, amber: 0.5, provisions: 0))
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(3_600), on: world)
        precondition(village.resources == Resources(wood: 65, amber: 31, provisions: 52))
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(21_600), on: world)
        precondition(village.bots.allSatisfy { $0.territory.count == 2 })
        precondition(village.resources == Resources(wood: 115, amber: 36, provisions: 62))
        let snapshot = village
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(21_600), on: world)
        precondition(village == snapshot, "A repeated time check must not duplicate production")
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(30 * 86_400), on: world)
        precondition(village.bots.allSatisfy { $0.territory.count <= 64 })
        let territories = village.bots.flatMap(\.territory)
        precondition(Set(territories).count == territories.count)
        precondition(!territories.contains(.home))
        precondition(territories.allSatisfy { $0.isValid && world.terrain(at: $0) != .sea })
        precondition(village.bots.allSatisfy { $0.territory.count <= 64 && $0.level <= 10 })
        let villageData = try JSONEncoder().encode(village)
        let restored = try JSONDecoder().decode(VillageState.self, from: villageData)
        precondition(restored == village)
        var legacyVillage = VillageState(seed: seed)
        legacyVillage.version = 4
        legacyVillage.buildings[13] = .farm
        legacyVillage.migrateIfNeeded(now: epoch)
        precondition(legacyVillage.version == 6 && legacyVillage.people == nil && legacyVillage.buildings[2] == .farm && legacyVillage.buildings[12] == .hall)
        var city = VillageState(seed: seed)
        precondition(city.build(.warehouse, at: 11) && city.storageCapacity == 800)
        precondition(city.build(.watchtower, at: 13) && city.automaticDefense == 2)
        city.resources = Resources(wood: 798, amber: 799, provisions: 800)
        city.lastProductionAt = epoch
        city.lastBotExpansionAt = epoch
        _ = city.updateInRealTime(now: epoch.addingTimeInterval(3_600), on: world)
        precondition(city.resources == Resources(wood: 800, amber: 800, provisions: 800), "Storage capacity must clamp each resource")
        var sauniers = VillageState(seed: seed)
        sauniers.people = .sauniers
        precondition(sauniers.build(.lumbermill, at: 0) && sauniers.build(.farm, at: 2))
        precondition(sauniers.production == Resources(wood: 11, amber: 1, provisions: 10))
        var nacre = VillageState(seed: seed)
        nacre.people = .nacre
        precondition(nacre.automaticDefense == 1)
        precondition(nacre.build(.watchtower, at: 13) && nacre.automaticDefense == 3)
        var roseaux = VillageState(seed: seed)
        roseaux.people = .roseaux
        precondition(roseaux.build(.lumbermill, at: 0) && roseaux.build(.amberWorks, at: 4))
        precondition(roseaux.production == Resources(wood: 10, amber: 6, provisions: 2))
        print("PASS: 40,000 tiles, seeded map, construction, continuous fractional accrual, offline bot growth and serialization")
        print("PASS: deterministic start, legal actions, costs, cap, serialization, UTC week boundaries")
    }
}
