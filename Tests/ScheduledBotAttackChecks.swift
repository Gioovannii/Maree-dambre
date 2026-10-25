import Foundation

func checkScheduledBotAttacks() throws {
    let now = Calendar.current.date(from: DateComponents(year: 2030, month: 3, day: 17, hour: 12))!
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    village.beginProtection(now: now)
    village.scheduleBotAttacks(now: now)
    let initialDue = village.scheduledBotAttackDate!
    let firstProtectionEnd = village.beginnerProtection!.endsAt
    precondition(initialDue >= firstProtectionEnd.addingTimeInterval(VillageState.minimumBotAttackInterval))
    precondition(initialDue <= firstProtectionEnd.addingTimeInterval(VillageState.maximumBotAttackInterval + 24 * 3600))
    village.scheduleBotAttacks(now: now.addingTimeInterval(3600))
    precondition(village.nextBotAttackAt == initialDue)
    precondition(village.extendProtection(now: now))
    let due = village.scheduledBotAttackDate!
    let extendedProtectionEnd = village.beginnerProtection!.endsAt
    precondition(due >= extendedProtectionEnd.addingTimeInterval(VillageState.minimumBotAttackInterval))
    precondition(due <= extendedProtectionEnd.addingTimeInterval(VillageState.maximumBotAttackInterval + 24 * 3600))
    village.resolveScheduledAttacks(now: due.addingTimeInterval(-1))
    precondition(village.coastalCampaign == nil)
    village.updateDomain(now: due, on: world)
    let firstResolved = (village.coastalCampaign?.assaultsResolved ?? 0)
        + (village.otherVillages ?? []).reduce(0) { $0 + ($1.coastalCampaign?.assaultsResolved ?? 0) }
    precondition(firstResolved == 1, "A scheduled raid targets one settlement across the account")
    precondition(([village] + (village.otherVillages ?? [])).compactMap(\.coastalCampaign).allSatisfy(\.isValid))
    precondition(village.allMail.filter { if case .defense = $0.content { true } else { false } }.count == 1)
    let afterAttack = village
    village.updateDomain(now: due, on: world)
    precondition(village.coastalCampaign == afterAttack.coastalCampaign)
    precondition(village.resources == afterAttack.resources && village.allMail == afterAttack.allMail)
    let later = due.addingTimeInterval(30 * 24 * 3600)
    village.updateDomain(now: later, on: world)
    let totalResolved = (village.coastalCampaign?.assaultsResolved ?? 0)
        + (village.otherVillages ?? []).reduce(0) { $0 + ($1.coastalCampaign?.assaultsResolved ?? 0) }
    precondition(totalResolved == 2, "A long absence resolves at most one additional raid")
    let nextDue = village.nextBotAttackAt!
    precondition(nextDue >= later.addingTimeInterval(VillageState.minimumBotAttackInterval))
    precondition(nextDue <= later.addingTimeInterval(VillageState.maximumBotAttackInterval + 24 * 3600))
    village.settlementRefuge = true
    village.updateDomain(now: later.addingTimeInterval(48 * 3600), on: world)
    precondition(village.scheduledBotAttackDate == nil)
    village.settlementRefuge = false
    let data = try JSONEncoder().encode(village)
    let restored = try JSONDecoder().decode(VillageState.self, from: data)
    precondition(restored.nextBotAttackAt == village.nextBotAttackAt)
    try checkAnnouncedRaidTargets()
    print("PASS: scheduled attacks, extension postponement, inactive villages, one attack per offline return, refuge and persisted deadlines")
}

private func checkAnnouncedRaidTargets() throws {
    var clock = Calendar.current.date(from: DateComponents(year: 2030, month: 4, day: 1, hour: 12))!
    var village = shipmentFixture(now: clock)
    village.scheduleBotAttacks(now: clock)
    var delays = Set<Int>()
    var hitLocations = Set<TileCoordinate>()
    for _ in 0..<24 {
        let due = village.nextDomainBotAttackDate!
        let target = village.botRaidTarget!
        let announced = village.nextBotRaidTargetName
        let alternate = village.otherVillages!.first!.location
        precondition(village.switchSettlement(to: alternate))
        precondition(village.botRaidTarget == target && village.nextBotRaidTargetName == announced,
                     "Switching the selected settlement must preserve the announced target")
        village = try JSONDecoder().decode(VillageState.self, from: JSONEncoder().encode(village))
        let oldIDs = Set(village.allMail.map(\.id))
        village.resolveScheduledAttacks(now: due)
        let reports = village.allMail.filter { !oldIDs.contains($0.id) }
        precondition(reports.count == 1 && reports[0].village == target,
                     "Exactly one report must belong to the announced settlement")
        hitLocations.insert(target)
        let next = village.nextDomainBotAttackDate!
        let delay = next.timeIntervalSince(due)
        precondition(delay >= VillageState.minimumBotAttackInterval && delay <= VillageState.maximumBotAttackInterval + 86400)
        delays.insert(Int(delay / 86400))
        village.resolveScheduledAttacks(now: due)
        precondition(village.allMail.count == oldIDs.count + 1, "Refreshing cannot duplicate a battle")
        clock = next
    }
    precondition(delays.count > 1 && hitLocations.count > 1, "Timing and targets must vary over successive raids")

    var night = shipmentFixture(now: clock)
    night.scheduleBotAttacks(now: clock)
    let target = night.botRaidTarget!
    let due = night.nextDomainBotAttackDate!
    let midnight = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: due)!
    night.resolveScheduledAttacks(now: midnight)
    precondition(night.botRaidTarget == target && night.coastalCampaign == nil,
                 "The nightly postponement must preserve the announced target")
    var colony = VillageState(seed: night.seed)
    colony.people = night.people
    colony.settlementLocation = TileCoordinate(x: 130, y: 130)
    colony.settlementRole = .outpost
    night.otherVillages!.append(colony)
    night.scheduleBotAttacks(now: midnight)
    precondition(night.botRaidTarget == target, "Founding another settlement must not reroll a pending target")
    let morning = night.nextDomainBotAttackDate!
    night.resolveScheduledAttacks(now: morning)
    precondition(night.allMail.first?.village == target)
    print("PASS: 24 raids, varied timing and targets, announced-village reports, save/reload, switching, night postponement and colony arrival")
}
