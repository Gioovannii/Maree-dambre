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
    print("PASS: scheduled attacks, extension postponement, inactive villages, one attack per offline return, refuge and persisted deadlines")
}
