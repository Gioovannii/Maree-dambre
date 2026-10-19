import Foundation

func checkMailbox() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    var village = shipmentFixture(now: now)
    let initialStock = village.resources
    village.receiveMail(.welcome, key: "welcome", at: now)
    village.receiveMail(.welcome, key: "welcome", at: now)
    precondition(village.allMail.count == 1 && village.unreadMailCount == 1)
    precondition(village.raid(targetID: 0, units: [.tideguard: 10], now: now))
    let firstReturn = village.army!.raid!.returnsAt
    village.updateArmy(now: firstReturn)
    let firstReport = village.army!.raidReport!
    precondition(village.allMail.count == 2)
    village.updateArmy(now: firstReturn)
    precondition(village.allMail.count == 2)
    precondition(village.raid(targetID: 1, units: [.tideguard: 10], now: firstReturn))
    village.updateArmy(now: village.army!.raid!.returnsAt)
    precondition(village.allMail.count == 3)
    precondition(village.allMail.contains { if case .raid(let report) = $0.content { report == firstReport } else { false } })
    let stock = village.resources
    let id = village.allMail.first!.id
    precondition(village.markMailRead(id) && !village.markMailRead(id))
    precondition(village.resources == stock && village.resources != initialStock)
    village.otherVillages![0].receiveMail(.welcome, key: "welcome", at: now)
    let ids = Set(village.allMail.map(\.id))
    precondition(ids.count == 4)
    let target = village.otherVillages![0].location
    precondition(village.switchSettlement(to: target))
    precondition(Set(village.allMail.map(\.id)) == ids)
    village.markAllMailRead()
    precondition(village.unreadMailCount == 0)
    precondition(village.switchSettlement(to: .home))
    precondition(village.startCoastalCampaign())
    precondition(village.advanceCoastalTide(now: now) && village.advanceCoastalTide(now: now.addingTimeInterval(1)))
    precondition(village.allMail.filter { if case .defense = $0.content { true } else { false } }.count == 1)
    let suite = "MareesAmbre.Mailbox.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    let world = WorldMap(seed: 42)
    try storage.save(village)
    let saved = try storage.load(seed: 42, world: world, now: now)!
    precondition(saved == village && saved.unreadMailCount == 1)
    var legacy = village
    legacy.version = 17
    legacy.mailbox = nil
    try storage.save(legacy)
    let migrated = try storage.load(seed: 42, world: world, now: now)!
    precondition(migrated.mailbox?.count == 4)
    precondition(migrated.mailbox!.filter { $0.imported == true }.count == 2)
    let again = try storage.load(seed: 42, world: world, now: now)!
    precondition(again == migrated, "Legacy reports are imported exactly once")
    var corrupt = saved
    corrupt.mailbox!.append(corrupt.mailbox![0])
    try storage.save(corrupt)
    do {
        _ = try storage.load(seed: 42, world: world, now: now)
        preconditionFailure("Duplicate mail IDs must be rejected")
    } catch { }
    var bounded = VillageState(seed: 42)
    for index in 0..<110 {
        bounded.receiveMail(.welcome, key: "notice.\(index)", at: now.addingTimeInterval(Double(index)))
    }
    precondition(bounded.allMail.count == VillageState.maximumMailPerVillage)
    precondition(bounded.allMail.last!.createdAt == now.addingTimeInterval(10))
    print("PASS: persistent mailbox, actual battle history, event deduplication, shared unread status, one-time legacy import and bounded validated storage")
}
