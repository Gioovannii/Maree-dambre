import Foundation

extension BuildingKind {
    func cost(for level: Int) -> Resources {
        let base = self == .hall ? Resources(wood: 40, amber: 10, provisions: 25) : cost
        return GameProgression.scaled(base, level: level, growth: 1.5)
    }
}

extension VillageState {
    func buildingLevel(_ kind: BuildingKind) -> Int {
        hasBuilding(kind) ? (buildingLevels?[kind] ?? 1) : 0
    }

    func buildingLevel(at plot: Int) -> Int {
        buildings[plot].map(buildingLevel) ?? 0
    }

    func constructionDuration(for level: Int) -> TimeInterval {
        ceil(GameProgression.duration(level: level, growth: 1.5)
             * pow(0.97, Double(max(0, buildingLevel(.hall) - 1))))
    }

    func resourceUpgradeDuration(for level: Int) -> TimeInterval {
        ceil(GameProgression.duration(level: level, growth: 1.45)
             * pow(0.97, Double(max(0, buildingLevel(.hall) - 1))))
    }

    var trainingSecondsPerUnit: TimeInterval {
        30 / (1 + 0.08 * Double(max(0, buildingLevel(.warCourt) - 1)))
    }

    var unitResearchDuration: TimeInterval {
        ceil(60 / (1 + 0.08 * Double(max(0, buildingLevel(.academy) - 1))))
    }

    func canUpgradeBuilding(at plot: Int) -> Bool {
        guard let kind = buildings[plot], construction == nil, resourceUpgrade == nil,
              buildingLevel(kind) < GameProgression.maximumBuildingLevel,
              meetsProductionRequirement(kind) else { return false }
        let cost = kind.cost(for: buildingLevel(kind) + 1)
        return resources.wood >= cost.wood && resources.amber >= cost.amber
            && resources.provisions >= cost.provisions
    }

    @discardableResult
    mutating func upgradeBuilding(at plot: Int, now: Date = .now) -> Bool {
        guard canUpgradeBuilding(at: plot), let kind = buildings[plot] else { return false }
        let target = buildingLevel(kind) + 1
        let cost = kind.cost(for: target)
        resources.wood -= cost.wood
        resources.amber -= cost.amber
        resources.provisions -= cost.provisions
        construction = ConstructionJob(plot: plot, kind: kind, startedAt: now,
                                       duration: constructionDuration(for: target),
                                       targetLevel: target, paidCost: cost)
        return true
    }
}
