import Foundation

func checkAbsenceSummary() {
    let date = Date(timeIntervalSince1970: 1_800_000_000)
    let world = WorldMap(seed: 42)
    var before = shipmentFixture(now: date)
    before.beginProtection(now: date)
    before.resources = Resources(wood: 100, amber: 100, provisions: 100)
    before.otherVillages?[0].resources = Resources(wood: 10, amber: 10, provisions: 10)
    before.army?.units = [.tideguard: 5]
    before.army?.training = TrainingOrder(unit: .tideguard, count: 3, endsAt: date.addingTimeInterval(60))
    before.otherVillages?[0].resourceUpgrade = ResourceUpgrade(plot: 0, targetLevel: 1, startedAt: date, cost: Resources(wood: 0, amber: 0, provisions: 0))
    let now = date.addingTimeInterval(3600)
    var after = before
    after.updateDomain(now: now, on: world)
    let summary = AbsenceSummary.between(before, and: after, now: now)!
    precondition(summary.completedWork == 1 && summary.trainedUnits == 3)
    precondition(summary.stockChange.wood == after.resources.wood + after.otherVillages![0].resources.wood - 110)
    precondition(summary.from == date && summary.until == now)
    precondition(AbsenceSummary.between(after, and: after, now: now) == nil)
    precondition(AbsenceSummary.between(before, and: after, now: date.addingTimeInterval(299)) == nil)
    precondition(AbsenceSummary.between(before, and: after, now: date.addingTimeInterval(-1)) == nil)
    precondition(AbsenceSummary.between(before, and: after, now: date.addingTimeInterval(300)) != nil)
    let report = HeroMissionReport(mission: .discoverWreck, experience: 30, materials: 2)
    after.receiveMail(.heroMission(report), key: "real", at: now)
    after.receiveMail(.heroMission(report), key: "legacy", at: now, imported: true)
    after.receiveMail(.welcome, key: "hello", at: now)
    let withReports = AbsenceSummary.between(before, and: after, now: now)!
    precondition(withReports.reports.count == 1 && withReports.reports[0].id.hasSuffix("real"))
    var old = before
    old.receiveMail(.heroMission(report), key: "real", at: date)
    precondition(AbsenceSummary.between(old, and: after, now: now)!.reports.isEmpty)
    after.resources.wood = 0
    precondition(AbsenceSummary.between(before, and: after, now: now)!.stockChange.wood < 0)
    after.resources.wood = after.storageCapacity
    precondition(AbsenceSummary.between(before, and: after, now: now)!.fullStores == 1)
    var unfounded = VillageState(seed: 42)
    unfounded.lastProductionAt = date
    precondition(AbsenceSummary.between(unfounded, and: after, now: now) == nil)
    print("PASS: offline summaries cover all villages, actual completed work and training, net stocks, imported reports and short absences")
}
