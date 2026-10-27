import Foundation

struct LighthouseProgress: Codable, Equatable {
    var completedStages = 0
    var startedAt: Date?
    var finishesAt: Date?
    var completedAt: Date?

    var isComplete: Bool { completedStages == LighthouseStage.allCases.count }
    var stage: LighthouseStage? { LighthouseStage(rawValue: completedStages) }
    var isValid: Bool {
        guard (0...LighthouseStage.allCases.count).contains(completedStages),
              [startedAt, finishesAt, completedAt].compactMap({ $0 }).allSatisfy({ $0 >= .distantPast && $0 <= .distantFuture }),
              (startedAt == nil) == (finishesAt == nil),
              isComplete == (completedAt != nil) else { return false }
        if let startedAt, let finishesAt {
            guard let stage, completedAt == nil,
                  abs(finishesAt.timeIntervalSince(startedAt) - stage.duration) < 0.01 else { return false }
        }
        return true
    }
}

extension VillageState {
    var lighthouseProgress: LighthouseProgress { lighthouse ?? LighthouseProgress() }
    var canStartLighthouseStage: Bool {
        guard people != nil, location == .home, settlementCount == Self.maximumSettlements,
              lighthouseProgress.isValid, lighthouseProgress.finishesAt == nil,
              let stage = lighthouseProgress.stage else { return false }
        return canAffordExpansion(stage.cost) && storageCapacity >= max(stage.cost.wood, stage.cost.amber, stage.cost.provisions)
    }

    @discardableResult
    mutating func startLighthouseStage(now: Date = .now) -> Bool {
        guard canStartLighthouseStage, now >= .distantPast, now <= .distantFuture,
              let stage = lighthouseProgress.stage else { return false }
        resources.wood -= stage.cost.wood
        resources.amber -= stage.cost.amber
        resources.provisions -= stage.cost.provisions
        var progress = lighthouseProgress
        progress.startedAt = now
        progress.finishesAt = now.addingTimeInterval(stage.duration)
        lighthouse = progress
        return true
    }

    mutating func updateLighthouse(now: Date) {
        guard var progress = lighthouse, progress.isValid, let end = progress.finishesAt, now >= end else { return }
        progress.completedStages += 1
        progress.startedAt = nil
        progress.finishesAt = nil
        if progress.isComplete {
            progress.completedAt = end
            nextBotAttackAt = nil
            botRaidTarget = nil
            for index in (otherVillages ?? []).indices { otherVillages?[index].nextBotAttackAt = nil }
        }
        lighthouse = progress
    }
}
