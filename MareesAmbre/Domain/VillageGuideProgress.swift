import Foundation

extension VillageState {
    var completedGuideObjectives: Set<VillageGuideStep> {
        var result = guideObjectives ?? []
        let hasEveryResource = ResourceSiteKind.allCases.allSatisfy { kind in
            VillageMapMode.resourceFields.slots.contains { ResourceSiteKind.at($0) == kind && resourceLevel(at: $0) > 0 }
        }
        if hasEveryResource || army?.raidReport != nil || army?.report != nil { result.insert(.fields) }
        if hasBuilding(.academy) { result.insert(.academy) }
        if !unlockedUnits.isEmpty || army?.raidReport != nil || army?.report != nil { result.insert(.research) }
        if hasBuilding(.warCourt) { result.insert(.barracks) }
        if availableArmy.values.contains(where: { $0 > 0 }) || army?.raid != nil || army?.convoy != nil
            || army?.raidReport != nil || army?.report != nil { result.insert(.train) }
        if army?.raidReport != nil || army?.report != nil { result.insert(.raid) }
        result.remove(.complete)
        return result
    }

    /// Start every resource stream before the tutorial commits the player to recruitment.
    var recommendedGuideResourcePlot: Int? {
        let missing = ResourceSiteKind.allCases.first { kind in
            !VillageMapMode.resourceFields.slots.contains { ResourceSiteKind.at($0) == kind && resourceLevel(at: $0) > 0 }
        }
        return VillageMapMode.resourceFields.slots.first { ResourceSiteKind.at($0) == missing }
    }

    var hasCompletedGuide: Bool { VillageGuideStep.next(in: self) == .complete }

    mutating func recordGuideProgress() {
        guideObjectives = completedGuideObjectives
    }
}
