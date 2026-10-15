import Foundation

struct ConvoyReport: Codable, Equatable {
    var order: ConvoyOrder
    var rewardClaimed = false

    var successful: Bool { order.power >= order.route.enemyPower }
    var amberReward: Int { successful ? order.route.amberReward : 0 }
    var pendingAmber: Int { rewardClaimed ? 0 : amberReward }
    var lossCount: Int { order.units.reduce(0) { $0 + losses(of: $1.key) } }
    var returnedCount: Int { order.units.values.reduce(0, +) - lossCount }
    var isValid: Bool { order.isValid && (!rewardClaimed || successful) }

    func losses(of unit: ArmyUnit) -> Int {
        let count = order.units[unit, default: 0]
        guard order.route.enemyPower > 0 else { return 0 }
        let losses = successful ? Int(floor(Double(count) * order.victoryLossRate + 1e-9))
            : Int(ceil(Double(count) * order.defeatLossRate - 1e-9))
        return min(count, max(0, losses))
    }
}
