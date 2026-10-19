import Foundation

func checkHeroMissions() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    precondition(village.customizeHero(portrait: .captainWoman, name: "Élyne", now: now))
    precondition(!village.startHeroMission(.repairBoat, now: now))
    precondition(!village.startHeroMission(.surveyCoast, now: now))
    let originalArmy = village.army
    precondition(village.startHeroMission(.discoverWreck, now: now))
    let first = village.hero!.missions!.voyage!
    let departed = village
    precondition(!village.startHeroMission(.discoverWreck, now: now) && village == departed)
    village.updateDomain(now: first.endsAt.addingTimeInterval(-1), on: world)
    precondition(village.hero?.missions?.chapter == 0)
    village.updateDomain(now: first.endsAt, on: world)
    precondition(village.hero?.missions?.chapter == 1 && village.hero?.missions?.materials == 2)
    precondition(village.hero?.totalExperience == 30 && village.army == originalArmy)
    village.updateDomain(now: first.endsAt, on: world)
    precondition(village.hero?.totalExperience == 30)
    precondition(village.startHeroMission(.recoverBoat, now: first.endsAt))
    let second = village.hero!.missions!.voyage!
    let colony = village.otherVillages![0].location
    precondition(village.switchSettlement(to: colony))
    village.updateDomain(now: second.endsAt, on: world)
    precondition(village.hero?.totalExperience == 80 && village.hero?.missions?.materials == 5)
    precondition(village.hero?.missions?.chapter == 2)
    precondition(village.otherVillages![0].mailbox?.contains { if case .heroMission(let report) = $0.content { report.mission == .recoverBoat } else { false } } == true)
    village.resources = Resources(wood: 199, amber: 80, provisions: 100)
    let poor = village
    precondition(!village.startHeroMission(.repairBoat, now: second.endsAt) && village == poor)
    village.resources = Resources(wood: 200, amber: 80, provisions: 100)
    precondition(village.startHeroMission(.repairBoat, now: second.endsAt))
    precondition(village.resources == Resources(wood: 0, amber: 0, provisions: 0))
    precondition(village.hero?.missions?.materials == 0)
    let repair = village.hero!.missions!.voyage!
    precondition(!village.startHeroMission(.repairBoat, now: second.endsAt))
    let suite = "MareesAmbre.HeroMissions.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(village)
    var reopened = try storage.load(seed: 42, world: world, now: second.endsAt)!
    precondition(reopened.hero?.missions?.voyage == repair)
    reopened.updateDomain(now: repair.endsAt.addingTimeInterval(10 * 86_400), on: world)
    precondition(reopened.hero?.missions?.hasBoat == true && reopened.hero?.missions?.chapter == 3)
    precondition(reopened.hero?.totalExperience == 155 && reopened.hero?.level == 2)
    precondition(reopened.allMail.filter { if case .heroMission = $0.content { true } else { false } }.count == 3)
    let settled = reopened.hero
    reopened.updateDomain(now: repair.endsAt.addingTimeInterval(10 * 86_400), on: world)
    precondition(reopened.hero == settled)
    precondition(!reopened.canStartHeroMission(.repairBoat))
    let departure = reopened.lastProductionAt!
    precondition(reopened.startHeroMission(.surveyCoast, now: departure))
    precondition(reopened.hero?.missions?.voyage?.duration == 900)
    let returnDate = reopened.hero!.missions!.voyage!.endsAt
    reopened.updateDomain(now: returnDate, on: world)
    precondition(reopened.hero?.totalExperience == 175 && reopened.hero?.missions?.materials == 1)
    precondition(reopened.canStartHeroMission(.surveyCoast) && reopened.canStartHeroMission(.rescueCrew))
    precondition(reopened.hero?.isValid == true)
    try storage.save(reopened)
    let final = try storage.load(seed: 42, world: world, now: returnDate)!
    precondition(final.hero == reopened.hero)
    var invalid = HeroMissions()
    invalid.chapter = 4
    precondition(!invalid.isValid)
    invalid.chapter = 0
    invalid.voyage = HeroVoyage(mission: .repairBoat, origin: .home, startedAt: now, duration: 1800)
    precondition(!invalid.isValid)
    invalid.voyage = HeroVoyage(mission: .discoverWreck, origin: .home, startedAt: now, duration: 1)
    precondition(!invalid.isValid)
    print("PASS: three hero missions, cross-village returns, atomic repair costs, offline boat unlock, faster repeatable voyages and no duplicate rewards")
}
