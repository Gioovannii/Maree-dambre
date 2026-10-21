import Foundation

struct RaidOrder: Codable, Equatable {
    static func casualtyRate(attackPower: Int, defense: Int, won: Bool, supportMultiplier: Double = 1) -> Double {
        let ratio = Double(max(0, attackPower)) / Double(max(1, defense))
        let baseRate: Double
        if won {
            // A decisive victory is clean; losses rise smoothly as the battle gets close.
            baseRate = min(0.2, max(0, 0.2 * (4 - ratio) / 3))
        } else {
            // A narrow defeat hurts less than sending a force into overwhelming defenses.
            baseRate = min(0.8, 0.2 + max(0, 1 - ratio) * 0.6)
        }
        return min(0.8, max(0, baseRate * min(1, max(0, supportMultiplier))))
    }

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
    var enemyUnits: [ArmyUnit: Int]? = nil
    var enemyFortifications: Int? = nil

    static func validEnemySnapshot(units: [ArmyUnit: Int]?, fortifications: Int?, defense: Int) -> Bool {
        guard let units else { return fortifications == nil }
        guard let fortifications, (1...5).contains(fortifications), !units.isEmpty,
              units.values.allSatisfy({ (1...4).contains($0) }) else { return false }
        return units.reduce(fortifications) { $0 + $1.key.defense * $1.value } == defense
    }
}
