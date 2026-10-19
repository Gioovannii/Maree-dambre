import Foundation

func checkRaidRest() {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(secondsFromGMT: 0)!
    func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        utc.date(from: DateComponents(year: 2030, month: 3, day: day, hour: hour, minute: minute))!
    }
    precondition(RaidRestPolicy.attackDate(for: date(17, 21, 59), calendar: utc) == date(17, 21, 59))
    precondition(RaidRestPolicy.attackDate(for: date(17, 22), calendar: utc) == date(18, 9))
    precondition(RaidRestPolicy.attackDate(for: date(18, 8), calendar: utc) == date(18, 9))
    precondition(RaidRestPolicy.attackDate(for: date(18, 9), calendar: utc) == date(18, 9))
    precondition(RaidRestPolicy.isQuiet(at: date(17, 22), calendar: utc))
    precondition(!RaidRestPolicy.isQuiet(at: date(18, 8), calendar: utc))
    var village = shipmentFixture(now: date(17, 12))
    village.nextBotAttackAt = date(17, 12)
    village.otherVillages?[0].nextBotAttackAt = date(17, 12)
    let army = village.army
    let resources = village.resources
    village.resolveScheduledAttacks(now: date(17, 23), calendar: utc)
    precondition(village.coastalCampaign == nil && village.army == army && village.resources == resources)
    precondition(village.nextBotAttackAt == date(18, 9) && village.otherVillages?[0].nextBotAttackAt == date(18, 9))
    village.resolveScheduledAttacks(now: date(18, 8, 59), calendar: utc)
    precondition(village.coastalCampaign == nil)
    village.resolveScheduledAttacks(now: date(18, 9), calendar: utc)
    precondition(village.coastalCampaign?.assaultsResolved == 1 && village.otherVillages?[0].coastalCampaign?.assaultsResolved == 1)
    precondition(village.nextBotAttackAt == date(19, 9))
    village.resolveScheduledAttacks(now: date(18, 9), calendar: utc)
    precondition(village.coastalCampaign?.assaultsResolved == 1)
    precondition(RaidRestPolicy.reminderDate(for: date(18, 9), now: date(17, 12), calendar: utc) == date(18, 8))
    precondition(RaidRestPolicy.reminderDate(for: date(18, 8), now: date(17, 12), calendar: utc) == nil)
    precondition(RaidRestPolicy.reminderDate(for: date(18, 12), now: date(18, 10), previousReminder: date(18, 8), calendar: utc) == nil)
    precondition(RaidRestPolicy.reminderDate(for: date(19, 12), now: date(18, 10), previousReminder: date(18, 8), calendar: utc) == date(19, 11))
    precondition(RaidRestPolicy.reminderDate(for: date(18, 9), now: date(18, 8, 30), calendar: utc) == nil)
    for zone in ["Europe/Paris", "Asia/Taipei", "America/New_York"] {
        var local = Calendar(identifier: .gregorian)
        local.timeZone = TimeZone(identifier: zone)!
        for month in [3, 10, 11] {
            let night = local.date(from: DateComponents(year: 2026, month: month, day: 28, hour: 23))!
            let morning = RaidRestPolicy.attackDate(for: night, calendar: local)
            precondition(morning > night && local.component(.hour, from: morning) == 9)
            precondition(!RaidRestPolicy.isQuiet(at: morning.addingTimeInterval(-3600), calendar: local))
        }
    }
    print("PASS: nightly raid protection, morning preparation hour, all villages, daily reminder cap and local calendar scheduling")
}
