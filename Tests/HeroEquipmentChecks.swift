import Foundation

func checkHeroEquipment() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    precondition(village.customizeHero(portrait: .captainWoman, name: "Élyne", now: now))
    village.hero?.missions = HeroMissions(chapter: 2, materials: 5)
    let beforeBoat = village
    precondition(!village.upgradeHeroEquipment(.spyglass) && village == beforeBoat)
    village.hero?.missions = HeroMissions(chapter: 3, materials: 200)
    village.hero?.experience = 100
    precondition(village.upgradeHeroEquipment(.spyglass))
    precondition(village.hero?.missions?.materials == 196)
    let tierOne = village
    precondition(!village.upgradeHeroEquipment(.spyglass) && village == tierOne)
    village.hero?.experience = 1000
    precondition(village.upgradeHeroEquipment(.spyglass) && village.upgradeHeroEquipment(.spyglass))
    for kind in [HeroEquipmentKind.outfit, .sail] {
        for _ in 1...3 { precondition(village.upgradeHeroEquipment(kind)) }
    }
    let full = village
    precondition(!village.upgradeHeroEquipment(.sail) && village == full)
    precondition(village.hero?.missions?.materials == 96)
    let equipment = village.hero!.missions!.equipment!
    precondition(equipment == HeroEquipment(spyglass: 3, outfit: 3, sail: 3))
    precondition(equipment.durationMultiplier == 0.6)
    precondition(equipment.experience(for: .surveyCoast) == 26 && equipment.materials(for: .surveyCoast) == 4)
    precondition(equipment.experience(for: .repairBoat) == 75 && equipment.materials(for: .repairBoat) == 0)
    precondition(village.army == beforeBoat.army && village.armyPower == beforeBoat.armyPower)
    precondition(village.raidDuration(to: village.bots[0]) == beforeBoat.raidDuration(to: beforeBoat.bots[0]))
    precondition(village.startHeroMission(.surveyCoast, now: now))
    precondition(village.hero?.missions?.voyage?.duration == 720)
    let departed = village
    precondition(!village.upgradeHeroEquipment(.spyglass) && village == departed)
    let destination = village.otherVillages![0].location
    precondition(village.switchSettlement(to: destination))
    let suite = "MareesAmbre.HeroEquipment.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(village)
    var restored = try storage.load(seed: 42, world: world, now: now)!
    restored.updateDomain(now: now.addingTimeInterval(720), on: world)
    precondition(restored.hero?.totalExperience == 1026)
    precondition(restored.hero?.missions?.materials == 100)
    precondition(restored.hero?.missions?.report?.experience == 26 && restored.hero?.missions?.report?.materials == 4)
    precondition(restored.hero?.missions?.report?.equipment == equipment && restored.hero?.isValid == true)
    let settled = restored.hero
    restored.updateDomain(now: now.addingTimeInterval(720), on: world)
    precondition(restored.hero == settled)
    try storage.save(restored)
    let again = try storage.load(seed: 42, world: world, now: now.addingTimeInterval(720))!
    precondition(again.hero == restored.hero)
    var poor = village
    poor.hero?.missions = HeroMissions(chapter: 3, materials: 3)
    let cannotPay = poor
    precondition(!poor.upgradeHeroEquipment(.spyglass) && poor == cannotPay)
    var invalid = HeroEquipment()
    invalid.sail = 4
    precondition(!invalid.isValid)
    var corrupt = restored
    corrupt.hero?.experience = 0
    precondition(corrupt.hero?.isValid == false)
    let oldVoyage = Data(#"{"mission":"surveyCoast","origin":{"x":100,"y":100},"startedAt":0,"duration":900}"#.utf8)
    let legacy = try JSONDecoder().decode(HeroVoyage.self, from: oldVoyage)
    precondition(legacy.equipment == nil && legacy.isValid)
    print("PASS: hero equipment costs, tier gates, boat safety, capped speed, frozen rewards, legacy voyages, persistence and unchanged armies")
}
