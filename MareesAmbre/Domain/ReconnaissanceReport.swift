import Foundation

enum ReconnaissanceDetail: String, Codable, CaseIterable, Identifiable {
    case standard, detailed
    var id: Self { self }
    var requiredAcademy: Int { self == .standard ? 1 : 3 }
    var title: String {
        switch self {
        case .standard: String(localized: "recon.normal", defaultValue: "Normal")
        case .detailed: String(localized: "recon.advanced", defaultValue: "Avancé")
        }
    }
}

struct ReconnaissanceReport: Codable, Equatable {
    let targetID: Int
    let level: Int
    let observedAt: Date
    let units: [ArmyUnit: Int]
    let fortifications: Int
    var detail: ReconnaissanceDetail? = nil
    // Earlier reports already exposed the complete composition.
    var effectiveDetail: ReconnaissanceDetail { detail ?? .detailed }

    var defensePower: Int { units.reduce(fortifications) { $0 + $1.key.defense * $1.value } }
    var isValid: Bool {
        (0...BotFaction.maximumStartingID).contains(targetID) && (1...10).contains(level)
            && observedAt >= .distantPast && observedAt <= .distantFuture
            && units == BotFaction(id: targetID, name: "", capital: .home, territory: [], level: level).garrison
            && fortifications == max(1, level / 2)
    }
    func isCurrent(for target: BotFaction, at now: Date) -> Bool {
        target.id == targetID && target.level == level && now >= observedAt
            && now.timeIntervalSince(observedAt) < 600
    }
}

extension VillageState {
    var reconnaissanceCost: Int { reconnaissanceCost(for: .standard) }
    func reconnaissanceCost(for detail: ReconnaissanceDetail) -> Int {
        (people == .roseaux ? 10 : 20) * (detail == .detailed ? 2 : 1)
    }

    @discardableResult
    mutating func observeNeighbor(_ id: Int, detail: ReconnaissanceDetail = .standard, now: Date = .now) -> Bool {
        let previous = army?.reconnaissance?[id]
        let cost = reconnaissanceCost(for: detail)
        guard buildingLevel(.academy) >= detail.requiredAcademy, resources.provisions >= cost,
              let target = bots.first(where: { $0.id == id }),
              !(previous?.isCurrent(for: target, at: now) == true
                && (previous?.effectiveDetail == .detailed || detail == .standard)) else { return false }
        resources.provisions -= cost
        var troops = army ?? ArmyState()
        if troops.reconnaissance == nil { troops.reconnaissance = [:] }
        troops.reconnaissance?[id] = ReconnaissanceReport(targetID: id, level: target.level,
            observedAt: now, units: target.garrison, fortifications: target.fortificationPower, detail: detail)
        army = troops
        return true
    }
}
