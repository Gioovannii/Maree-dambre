import Foundation

func checkHeroExperience() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    let raid = RaidReport(targetName: "Liora", attackPower: 100, defensePower: 14,
                          unitsSent: [.tideguard: 10], losses: [:], stolen: Resources(wood: 0, amber: 0, provisions: 0))
    var village = shipmentFixture(now: now)
    precondition(village.customizeHero(portrait: .captainWoman, name: "Élyne", now: now))
    precondition(village.hero?.level == 1 && village.hero?.experienceForNextLevel == 100)
    village.receiveMail(.raid(raid), key: "old", at: now.addingTimeInterval(-1))
    village.receiveMail(.raid(raid), key: "one", at: now)
    village.otherVillages?[0].receiveMail(.raid(raid), key: "repeat", at: now.addingTimeInterval(1))
    village.awardHeroExperience()
    precondition(village.hero?.totalExperience == 20)
    precondition(village.allMail.first { $0.id.hasSuffix(".one") }?.heroExperienceGain == 20)
    precondition(village.otherVillages?[0].mailbox?.last?.heroExperienceGain == 0)
    let settled = village
    village.awardHeroExperience()
    precondition(village == settled)
    let nextDay = now.addingTimeInterval(86_400)
    village.receiveMail(.raid(raid), key: "tomorrow", at: nextDay)
    village.awardHeroExperience()
    precondition(village.hero?.totalExperience == 40)
    village.receiveMail(.raid(raid), key: "late-old-day", at: now.addingTimeInterval(10))
    village.awardHeroExperience()
    precondition(village.hero?.totalExperience == 40)

    // Renaming, portrait edits and village changes preserve all progression and reward limits.
    let progression = village.hero
    precondition(village.customizeHero(portrait: .captainMan, name: "Maël", now: nextDay))
    precondition(village.hero?.experience == progression?.experience && village.hero?.rewardKeys == progression?.rewardKeys)
    precondition(village.switchSettlement(to: village.otherVillages![0].location))
    precondition(village.hero?.totalExperience == 40)

    var captain = village.hero!
    for (xp, level, within, needed) in [(99, 1, 99, 100), (100, 2, 0, 150), (249, 2, 149, 150), (250, 3, 0, 200)] {
        captain.experience = xp
        precondition(captain.level == level && captain.experienceInLevel == within && captain.experienceForNextLevel == needed)
    }
    captain.experience = HeroProgression.maximumExperience
    precondition(captain.level == 20 && captain.isMaximumLevel && captain.experienceForNextLevel == 0)
    captain.experience = -1
    precondition(!captain.isValid)
    captain.experience = HeroProgression.maximumExperience + 1
    precondition(!captain.isValid)

    // Defensive rewards are bounded per village and day, including manually advanced tides.
    var defended = shipmentFixture(now: now)
    precondition(defended.customizeHero(portrait: .captainWoman, name: "Élyne", now: now))
    precondition(defended.startCoastalCampaign())
    for _ in 0..<5 { precondition(defended.advanceCoastalTide(now: now)) }
    defended.awardHeroExperience()
    precondition(defended.hero?.totalExperience == 20)
    let voyage = FoundingVoyage(destination: defended.otherVillages![0].location, role: .production,
                               isRefuge: false, escort: .tideguard, arrivesAt: now)
    defended.receiveMail(.colony(voyage), key: "colony-test", at: now)
    defended.awardHeroExperience()
    precondition(defended.hero?.totalExperience == 95)
    defended.hero?.experience = HeroProgression.maximumExperience - 3
    defended.receiveMail(.raid(raid), key: "cap-test", at: now)
    defended.awardHeroExperience()
    precondition(defended.hero?.totalExperience == HeroProgression.maximumExperience)
    precondition(defended.allMail.first { $0.id.hasSuffix(".cap-test") }?.heroExperienceGain == 3)
    precondition(defended.hero?.isValid == true)

    // A real returning expedition awards XP once through the shared domain clock.
    var real = shipmentFixture(now: now)
    precondition(real.customizeHero(portrait: .captainWoman, name: "Élyne", now: now))
    precondition(real.raid(targetID: 0, units: [.tideguard: 5], now: now))
    real.updateDomain(now: now.addingTimeInterval(3600), on: world)
    precondition(real.hero?.totalExperience == 20)
    real.updateDomain(now: now.addingTimeInterval(3600), on: world)
    precondition(real.hero?.totalExperience == 20)
    let suite = "MareesAmbre.HeroXP.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(real)
    var loaded = try storage.load(seed: 42, world: world, now: now.addingTimeInterval(3600))!
    loaded.awardHeroExperience()
    precondition(loaded.hero?.totalExperience == 20 && loaded.hero == real.hero)

    // A legacy portrait has no retroactive XP from previously stored reports.
    let legacyData = Data(#"{"portrait":"captainWoman","name":"Élyne"}"#.utf8)
    real.hero = try JSONDecoder().decode(PlayerHero.self, from: legacyData)
    real.initializeHeroProgression(now: now.addingTimeInterval(7200))
    real.awardHeroExperience()
    precondition(real.hero?.totalExperience == 0)
    print("PASS: hero XP thresholds, daily shared raid limits, edits, old reports, real offline combat, persistence and no duplicate XP")
}
