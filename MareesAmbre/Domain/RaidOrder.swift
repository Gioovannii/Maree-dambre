import Foundation

struct RaidOrder: Codable, Equatable {
    static func casualties(units: [ArmyUnit: Int], rate: Double, roundUp: Bool) -> [ArmyUnit: Int] {
        let counts = units.filter { $0.value > 0 }
        let total = counts.values.reduce(0, +)
        guard total > 0 else { return [:] }

        let boundedRate = min(1, max(0, rate))
        let expectedTotal = Double(total) * boundedRate
        let target = min(total, max(0, roundUp
            ? Int(ceil(expectedTotal - 1e-9))
            : Int(floor(expectedTotal + 1e-9))))

        var losses: [ArmyUnit: Int] = [:]
        var fractions: [(unit: ArmyUnit, fraction: Double)] = []
        var assigned = 0
        for (unit, count) in counts {
            let exact = Double(count) * boundedRate
            let base = min(count, Int(floor(exact)))
            losses[unit] = base
            assigned += base
            fractions.append((unit, exact - Double(base)))
        }

        let remaining = max(0, target - assigned)
        for entry in fractions.sorted(by: {
            $0.fraction == $1.fraction
                ? $0.unit.rawValue < $1.unit.rawValue
                : $0.fraction > $1.fraction
        }).prefix(remaining) {
            losses[entry.unit, default: 0] += 1
        }

        return losses.filter { $0.value > 0 }
    }

    var targetDisplayName: String {
        targetName
    }
    var attackPower: Int {
        units.reduce(0) { $0 + ($1.key.attack + (weaponLevels?[$1.key] ?? attackUpgrade ?? 0)) * $1.value }
    }

    let targetID: Int
    let targetName: String
    let units: [ArmyUnit: Int]
    let defense: Int
    let returnsAt: Date
    var attackUpgrade: Int? = nil
    var victoryLossRate: Double? = nil
    var defeatLossRate: Double? = nil
    var transportBonusPercent: Int? = nil
    var lootLimit: Int? = nil
    var weaponLevels: [ArmyUnit: Int]? = nil
}
