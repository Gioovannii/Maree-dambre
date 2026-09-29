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
        precondition(!village.canBuild(.lumbermill, at: 11))
        precondition(!village.canBuild(.hall, at: 11) && !village.canBuild(.farm, at: 12))
        precondition(ResourceSiteKind.at(0) == .woodland && ResourceSiteKind.at(2) == .cropland)
        precondition(ResourceSiteKind.at(4) == .amberVein && ResourceSiteKind.at(12) == nil)
        precondition(village.canDevelopResource(at: 0) && village.resourceLevel(at: 0) == 0)
        precondition(village.developResource(at: 0) && village.resourceLevel(at: 0) == 1)
        precondition(village.resources == Resources(wood: 75, amber: 35, provisions: 60))
        village.resourceLevels = [0: 9]
        precondition(!village.canBuild(.lumbermill, at: 11))
        village.resourceLevels = [0: 10]
        precondition(village.canBuild(.lumbermill, at: 11), "One matching level 10 field is sufficient")
        precondition(!village.canBuild(.farm, at: 13) && !village.canBuild(.amberWorks, at: 13))
        precondition(village.build(.lumbermill, at: 11))
        precondition(village.construction?.kind == .lumbermill)
        village.updateConstruction(now: village.construction!.endsAt.addingTimeInterval(1))
        precondition(village.buildings[0] == nil && village.buildings[11] == .lumbermill)
        let stockAfterMill = village.resources
        precondition(!village.canBuild(.lumbermill, at: 16))
        precondition(!village.build(.lumbermill, at: 16) && village.resources == stockAfterMill,
                     "A building type can be built only once")
        precondition(village.production == Resources(wood: 90, amber: 1, provisions: 2))
        village.resourceLevels = [0: 9]
        precondition(village.production.wood == 74, "Existing mill is inactive below the prerequisite")
        village.resourceLevels = [0: 10]
        precondition(village.canMoveBuilding(from: 11, to: 16))
        precondition(village.moveBuilding(from: 11, to: 16))
        precondition(!village.canMoveBuilding(from: 16, to: 0), "Buildings stay in the Centre-ville")
        precondition(!village.canMoveBuilding(from: 12, to: 13), "Town hall stays in place")
        let epoch = Date(timeIntervalSince1970: 1_800_000_000)
        let beforeOffline = village.resources
        village.lastProductionAt = epoch
        village.lastBotExpansionAt = epoch
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(1_800), on: world)
        precondition(village.resources == Resources(wood: beforeOffline.wood + 45,
                                                   amber: beforeOffline.amber,
                                                   provisions: beforeOffline.provisions + 1))
        precondition(village.productionRemainder == ProductionRemainder(wood: 0, amber: 0.5, provisions: 0))
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(3_600), on: world)
        precondition(village.resources == Resources(wood: beforeOffline.wood + 90,
                                                   amber: beforeOffline.amber + 1,
                                                   provisions: beforeOffline.provisions + 2))
        let snapshot = village
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(3_600), on: world)
        precondition(village == snapshot, "A repeated check cannot duplicate offline production")
        _ = village.updateInRealTime(now: epoch.addingTimeInterval(6 * 3_600), on: world)
        precondition(village.bots.allSatisfy { $0.territory.count == 2 })
        village.resources = Resources(wood: 1_000, amber: 1_000, provisions: 1_000)
        village.resourceLevels = [0: 9]
        precondition(village.developResource(at: 0))
        precondition(village.resourceLevel(at: 0) == 10 && !village.canDevelopResource(at: 0))
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
        precondition(restoredOldSave.version == 9)
        precondition(restoredOldSave.buildings[0] == nil && restoredOldSave.buildings[2] == nil)
        precondition(restoredOldSave.resourceLevel(at: 0) == 1 && restoredOldSave.resourceLevel(at: 2) == 1)
        precondition(restoredOldSave.production == oldProduction, "Migration preserves hourly production")
        var legacyVillage = VillageState(seed: seed)
        legacyVillage.version = 4
        legacyVillage.resourceLevels = nil
        legacyVillage.buildings[13] = .farm
        legacyVillage.migrateIfNeeded(now: epoch)
        precondition(legacyVillage.version == 9 && legacyVillage.resourceLevel(at: 2) == 1)
        precondition(legacyVillage.buildings[12] == .hall && legacyVillage.buildings[13] == nil)

        var duplicatedVillage = VillageState(seed: seed)
        duplicatedVillage.version = 7
        duplicatedVillage.resources = Resources(wood: 100, amber: 50, provisions: 60)
        duplicatedVillage.buildings = [10: .watchtower, 11: .watchtower, 12: .hall, 13: .farm, 14: .farm]
        duplicatedVillage.migrateIfNeeded(now: epoch)
        precondition(duplicatedVillage.version == 9)
        precondition(duplicatedVillage.buildings[10] == .watchtower && duplicatedVillage.buildings[11] == nil)
        precondition(duplicatedVillage.buildings[13] == .farm && duplicatedVillage.buildings[14] == nil)
        precondition(duplicatedVillage.resources == Resources(wood: 155, amber: 58, provisions: 85),
                     "Removed duplicates refund their construction cost")
        precondition(!duplicatedVillage.canBuild(.watchtower, at: 16))
        precondition(duplicatedVillage.canMoveBuilding(from: 10, to: 16),
                     "A unique building can still be moved")

        var city = VillageState(seed: seed)
        precondition(city.build(.warehouse, at: 11))
        city.updateConstruction(now: city.construction!.endsAt.addingTimeInterval(1))
        precondition(city.storageCapacity == 800)
        precondition(city.build(.watchtower, at: 13))
        city.updateConstruction(now: city.construction!.endsAt.addingTimeInterval(1))
        precondition(city.automaticDefense == 2)
        var nacre = VillageState(seed: seed)
        nacre.people = .nacre
        precondition(nacre.automaticDefense == 1)
        precondition(nacre.build(.watchtower, at: 13))
        nacre.updateConstruction(now: nacre.construction!.endsAt.addingTimeInterval(1))
        precondition(nacre.automaticDefense == 3)
        var military = VillageState(seed: seed)
        precondition(!military.canTrain(.tideguard, count: 1))
        precondition(!military.research(.tideguard, now: epoch))
        military.buildings[10] = .academy
        military.buildings[11] = .warCourt
        precondition(!military.canTrain(.tideguard, count: 1))
        precondition(military.research(.tideguard, now: epoch.addingTimeInterval(-60)))
        precondition(!military.research(.reedrunner, now: epoch.addingTimeInterval(-59)))
        precondition(!military.canTrain(.tideguard, count: 1))
        military = try JSONDecoder().decode(VillageState.self, from: JSONEncoder().encode(military))
        military.updateArmy(now: epoch)
        precondition(military.unlockedUnits.contains(.tideguard))
        precondition(!military.canResearch(.tideguard))
        precondition(!military.canTrain(.amberSentry, count: 1))
        military.resources = Resources()
        precondition(!military.train(.tideguard, count: -1, now: epoch))
        precondition(military.train(.tideguard, count: 4, now: epoch))
        precondition(!military.train(.reedrunner, count: 1, now: epoch))
        military.updateArmy(now: epoch.addingTimeInterval(119))
        precondition(military.availableArmy.isEmpty)
        military.updateArmy(now: epoch.addingTimeInterval(120))
        precondition(military.availableArmy[.tideguard] == 4)
        precondition(military.raid(targetID: 0, now: epoch.addingTimeInterval(120)))
        precondition(military.availableArmy.isEmpty)
        precondition(!military.raid(targetID: 1, now: epoch.addingTimeInterval(120)))
        let savedArmy = try JSONEncoder().encode(military)
        military = try JSONDecoder().decode(VillageState.self, from: savedArmy)
        military.updateArmy(now: epoch.addingTimeInterval(240))
        precondition(military.availableArmy[.tideguard] == 4)
        precondition(military.resources == Resources(wood: 68, amber: 55, provisions: 40))
        let settled = military
        military.updateArmy(now: epoch.addingTimeInterval(241))
        precondition(military == settled, "A returned raid must never award loot twice")
        precondition(!military.raid(targetID: 0, now: epoch.addingTimeInterval(241)))
        precondition(!military.raid(targetID: 0, now: epoch.addingTimeInterval(839)))
        precondition(settled.canRaid(settled.bots[0], now: epoch.addingTimeInterval(840)),
                     "A target recovers ten minutes after the two-minute return")
        military.army?.units = [.reedrunner: 1]
        precondition(military.raid(targetID: 1, now: epoch.addingTimeInterval(241)))
        military.updateArmy(now: epoch.addingTimeInterval(361))
        precondition(military.availableArmy[.reedrunner] == 0)
        precondition(military.resources == settled.resources)
        var priorArmy = VillageState(seed: seed)
        priorArmy.army = ArmyState(units: [.reedrunner: 3])
        priorArmy.updateArmy(now: epoch)
        precondition(priorArmy.unlockedUnits == [.reedrunner])
        precondition(!priorArmy.canTrain(.reedrunner, count: 1), "The training building remains required")
        precondition(priorArmy.availableArmy[.reedrunner] == 3)
        var freshStart = VillageState(seed: seed)
        freshStart.people = .sauniers
        var playTime = Date.now
        let playStartedAt = playTime
        while freshStart.resourceLevel(at: 0) < ResourceSiteKind.maximumLevel {
            if freshStart.canDevelopResource(at: 0) {
                precondition(freshStart.developResource(at: 0))
            } else {
                playTime = playTime.addingTimeInterval(60)
                _ = freshStart.updateInRealTime(now: playTime, on: world)
            }
            precondition(playTime.timeIntervalSince(playStartedAt) < 6 * 3_600,
                         "A fresh village must reach the first level-10 field before the first faction upgrade")
        }
        while !freshStart.canBuild(.academy, at: 10) {
            playTime = playTime.addingTimeInterval(60)
            _ = freshStart.updateInRealTime(now: playTime, on: world)
        }
        precondition(playTime.timeIntervalSince(playStartedAt) < 6 * 3_600)
        precondition(freshStart.build(.academy, at: 10))
        playTime = playTime.addingTimeInterval(61)
        _ = freshStart.updateInRealTime(now: playTime, on: world)
        while !freshStart.canBuild(.warCourt, at: 11) {
            playTime = playTime.addingTimeInterval(60)
            _ = freshStart.updateInRealTime(now: playTime, on: world)
        }
        precondition(freshStart.build(.warCourt, at: 11))
        playTime = playTime.addingTimeInterval(61)
        _ = freshStart.updateInRealTime(now: playTime, on: world)
        while !freshStart.canResearch(.tideguard) {
            playTime = playTime.addingTimeInterval(60)
            _ = freshStart.updateInRealTime(now: playTime, on: world)
        }
        precondition(freshStart.research(.tideguard, now: playTime))
        playTime = playTime.addingTimeInterval(61)
        freshStart.updateArmy(now: playTime)
        while !freshStart.canTrain(.tideguard, count: 2) {
            playTime = playTime.addingTimeInterval(60)
            _ = freshStart.updateInRealTime(now: playTime, on: world)
        }
        precondition(freshStart.train(.tideguard, count: 2, now: playTime))
        playTime = playTime.addingTimeInterval(61)
        freshStart.updateArmy(now: playTime)
        precondition(freshStart.raid(targetID: 0, now: playTime))
        let savedFirstRaid = try JSONDecoder().decode(VillageState.self, from: JSONEncoder().encode(freshStart))
        precondition(savedFirstRaid.army?.isValid == true, "The first raid must remain valid when loading its save")
        var occupiedSite = freshStart
        occupiedSite.construction = ConstructionJob(plot: 16, kind: .warehouse, startedAt: playTime, duration: 60)
        precondition(!occupiedSite.canMoveBuilding(from: 10, to: 16), "Moving must not overwrite a construction site")
        precondition(playTime.timeIntervalSince(playStartedAt) < 6 * 3_600,
                     "The intended first raid fits within the first faction expansion window")
        print("PASS: training costs, offline completion, raid losses, loot, cooldown, save/resume and no duplicate rewards")
        print("PASS: a new village can develop, research, train and launch its first raid within six hours")
        print("PASS: 40,000 tiles, unique city buildings, resource sites, offline production and legacy migration")
        print("PASS: deterministic start, legal actions, costs, cap, serialization, UTC week boundaries")
    }
}
