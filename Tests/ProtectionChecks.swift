import Foundation

func checkBeginnerProtection() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    village.beginProtection(now: now)
    let initialEnd = now.addingTimeInterval(72 * 3600)
    precondition(village.beginnerProtection?.endsAt == initialEnd)
    precondition(village.isUnderProtection(at: initialEnd.addingTimeInterval(-1)))
    precondition(!village.isUnderProtection(at: initialEnd))
    precondition(village.canRaid(village.bots[0], units: [.tideguard: 10], now: now))
    precondition(village.startCoastalCampaign())
    let stocks = village.resources
    let troops = village.availableArmy
    for index in 0..<6 { precondition(village.advanceCoastalTide(now: now.addingTimeInterval(Double(index)))) }
    precondition(village.resources == stocks && village.availableArmy == troops)
    precondition(village.coastalCampaign?.report == nil && village.coastalCampaign?.isValid == true)
    precondition(village.defensePreview(at: now) == nil)
    let marketPlot = VillageMapMode.townCenter.slots.first { village.buildings[$0] == nil && VillageState.canPlace(.market, at: $0) }!
    village.buildings[marketPlot] = .market
    precondition(village.sendConvoy(on: .sheltered, units: [.tideguard: 1]))
    for index in 0..<3 { precondition(village.advanceCoastalTide(now: now.addingTimeInterval(Double(index + 7)))) }
    precondition(village.army?.convoy == nil && village.commerce?.report?.successful == true)
    precondition(village.coastalCampaign?.report == nil && village.availableArmy == troops)
    precondition(village.extendProtection(now: now.addingTimeInterval(71 * 3600)))
    let extendedEnd = now.addingTimeInterval(120 * 3600)
    precondition(village.beginnerProtection?.endsAt == extendedEnd)
    let extended = village
    precondition(!village.extendProtection(now: now.addingTimeInterval(72 * 3600)) && village == extended)
    let colony = village.otherVillages![0].location
    precondition(village.switchSettlement(to: colony))
    precondition(village.beginnerProtection?.endsAt == extendedEnd && village.beginnerProtection?.extensionUsed == true)
    precondition(village.otherVillages![0].beginnerProtection == nil)
    precondition(village.switchSettlement(to: .home))
    village.updateDomain(now: extendedEnd, on: world)
    precondition(!village.isUnderProtection(at: extendedEnd))
    precondition(village.allMail.filter { if case .protectionEnded = $0.content { true } else { false } }.count == 1)
    village.updateDomain(now: extendedEnd, on: world)
    precondition(village.allMail.filter { if case .protectionEnded = $0.content { true } else { false } }.count == 1)
    precondition(village.advanceCoastalTide(now: extendedEnd))
    precondition(village.coastalCampaign?.report != nil && village.coastalCampaign?.isValid == true)
    precondition(village.availableArmy[.tideguard, default: 0] < troops[.tideguard, default: 0])
    var expired = shipmentFixture(now: now)
    expired.beginProtection(now: now)
    let before = expired
    precondition(!expired.extendProtection(now: initialEnd) && expired == before)
    let suite = "MareesAmbre.Protection.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(village)
    let saved = try storage.load(seed: 42, world: world, now: extendedEnd)!
    precondition(saved == village)
    var legacy = shipmentFixture(now: now)
    legacy.version = 18
    try storage.save(legacy)
    let migrated = try storage.load(seed: 42, world: world, now: now)!
    precondition(migrated.beginnerProtection?.endsAt == initialEnd)
    let again = try storage.load(seed: 42, world: world, now: now.addingTimeInterval(3600))!
    precondition(again.beginnerProtection?.endsAt == initialEnd)
    print("PASS: 72-hour domain protection, one additive 48-hour extension, safe coastal tides, continuing commerce, expiry and migration without timer resets")
}
