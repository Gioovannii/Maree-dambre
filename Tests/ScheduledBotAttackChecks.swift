import Foundation

func checkScheduledBotAttacks() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    village.beginProtection(now: now)
    village.scheduleBotAttacks(now: now)
    let initialDue = now.addingTimeInterval(96 * 3600)
    precondition(village.scheduledBotAttackDate == initialDue)
    village.scheduleBotAttacks(now: now.addingTimeInterval(3600))
    precondition(village.nextBotAttackAt == initialDue)
    precondition(village.extendProtection(now: now))
    let due = now.addingTimeInterval(144 * 3600)
    precondition(village.scheduledBotAttackDate == due)
    village.resolveScheduledAttacks(now: due.addingTimeInterval(-1))
    precondition(village.coastalCampaign == nil)
    village.updateDomain(now: due, on: world)
    precondition(village.coastalCampaign?.assaultsResolved == 1)
    precondition(village.coastalCampaign?.isValid == true)
    precondition(village.otherVillages?.first?.coastalCampaign?.assaultsResolved == 1)
    precondition(village.allMail.filter { if case .defense = $0.content { true } else { false } }.count == 2)
    let afterAttack = village
    village.updateDomain(now: due, on: world)
    precondition(village.coastalCampaign == afterAttack.coastalCampaign)
    precondition(village.resources == afterAttack.resources && village.allMail == afterAttack.allMail)
    let later = due.addingTimeInterval(30 * 24 * 3600)
    village.updateDomain(now: later, on: world)
    precondition(village.coastalCampaign?.assaultsResolved == 2)
    precondition(village.nextBotAttackAt == later.addingTimeInterval(24 * 3600))
    village.settlementRefuge = true
    village.updateDomain(now: later.addingTimeInterval(48 * 3600), on: world)
    precondition(village.coastalCampaign?.assaultsResolved == 2 && village.scheduledBotAttackDate == nil)
    village.settlementRefuge = false
    let data = try JSONEncoder().encode(village)
    let restored = try JSONDecoder().decode(VillageState.self, from: data)
    precondition(restored.nextBotAttackAt == village.nextBotAttackAt)
    print("PASS: scheduled attacks, extension postponement, inactive villages, one attack per offline return, refuge and persisted deadlines")
}
