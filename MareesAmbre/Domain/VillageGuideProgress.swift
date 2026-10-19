import Foundation

extension VillageState {
    var completedGuideObjectives: Set<VillageGuideStep> {
        var result = guideObjectives ?? []
        if (resourceLevels ?? [:]).values.contains(where: { $0 > 0 }) { result.insert(.fields) }
        if hasBuilding(.academy) { result.insert(.academy) }
        if !unlockedUnits.isEmpty || army?.raidReport != nil || army?.report != nil { result.insert(.research) }
        if hasBuilding(.warCourt) { result.insert(.barracks) }
        if availableArmy.values.contains(where: { $0 > 0 }) || army?.raid != nil || army?.convoy != nil
            || army?.raidReport != nil || army?.report != nil { result.insert(.train) }
        if army?.raidReport != nil || army?.report != nil { result.insert(.raid) }
        result.remove(.complete)
        return result
    }

    var hasCompletedGuide: Bool { VillageGuideStep.next(in: self) == .complete }

    mutating func recordGuideProgress() {
        guideObjectives = completedGuideObjectives
    }
}
