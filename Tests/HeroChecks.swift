import Foundation

func checkHero() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    precondition(village.customizeHero(portrait: .captainWoman, name: "  Élyne 🌊  "))
    precondition(village.hero?.name == "Élyne 🌊")
    let before = village
    for invalid in ["", "   ", "a\nb", "a\tb", String(repeating: "a", count: 25)] {
        precondition(!village.customizeHero(portrait: .captainMan, name: invalid) && village == before)
    }
    let target = village.otherVillages![0].location
    precondition(village.switchSettlement(to: target))
    precondition(village.hero == before.hero && village.otherVillages!.allSatisfy { $0.hero == nil })
    precondition(village.customizeHero(portrait: .captainMan, name: "Maël"))
    precondition(village.switchSettlement(to: .home))
    precondition(village.hero?.portrait == .captainMan && village.hero?.name == "Maël")
    let suite = "MareesAmbre.Hero.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(village)
    let loaded = try storage.load(seed: 42, world: world, now: now)!
    precondition(loaded.hero == village.hero)
    var legacy = village
    legacy.hero = nil
    try storage.save(legacy)
    let oldSave = try storage.load(seed: 42, world: world, now: now)!
    precondition(oldSave.hero == nil)
    print("PASS: hero choice, Unicode name validation, edits, shared identity across settlements and old-save compatibility")
}
