import Foundation

/// A view of the last offline update, never a second source of rewards.
struct AbsenceSummary: Equatable {
    static let minimumDuration: TimeInterval = 5 * 60
    let from: Date
    let until: Date
    let stockChange: Resources
    let completedWork: Int
    let trainedUnits: Int
    let reports: [GameMail]
    let newVillages: Int
    let fullStores: Int

    static func between(_ before: VillageState, and after: VillageState, now: Date) -> Self? {
        guard before.people != nil, let from = before.lastProductionAt,
              now.timeIntervalSince(from) >= minimumDuration else { return nil }
        let oldVillages = [before] + (before.otherVillages ?? [])
        let villages = [after] + (after.otherVillages ?? [])
        func total(_ states: [VillageState], _ kind: ResourceKind) -> Int {
            states.reduce(0) { $0 + $1.resources[kind] }
        }
        var work = 0
        var trained = 0
        for old in oldVillages {
            guard let current = villages.first(where: { $0.location == old.location }) else { continue }
            if let job = old.construction, job.endsAt <= now,
               current.construction == nil, current.buildingLevel(job.kind) >= job.level { work += 1 }
            if let job = old.resourceUpgrade, job.endsAt <= now,
               current.resourceUpgrade == nil, current.resourceLevel(at: job.plot) >= job.targetLevel { work += 1 }
            if let job = old.weaponUpgrade, job.endsAt <= now, current.weaponUpgrade == nil { work += 1 }
            if let job = old.army?.research, job.endsAt <= now, current.army?.research == nil { work += 1 }
            if let job = old.army?.training, job.endsAt <= now, current.army?.training == nil { trained += job.count }
        }
        let oldIDs = Set(before.allMail.map(\.id))
        let reports = after.allMail.filter { !oldIDs.contains($0.id) && $0.imported != true && $0.content.isReport }
        return Self(from: from, until: now,
                    stockChange: Resources(wood: total(villages, .wood) - total(oldVillages, .wood),
                                           amber: total(villages, .amber) - total(oldVillages, .amber),
                                           provisions: total(villages, .provisions) - total(oldVillages, .provisions)),
                    completedWork: work, trainedUnits: trained, reports: reports,
                    newVillages: max(0, villages.count - oldVillages.count),
                    fullStores: villages.reduce(0) { count, village in
                        count + ResourceKind.allCases.filter { village.resources[$0] >= village.storageCapacity }.count
                    })
    }
}
