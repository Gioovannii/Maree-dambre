import Foundation

struct ConvoyOrder: Codable, Equatable {
    var route: TradeRoute
    var departedAtTide: Int
    var units: [ArmyUnit: Int]
    var attackUpgrade: Int
    var transportBonusPercent: Int
    var victoryLossRate: Double
    var defeatLossRate: Double

    var returnsAtTide: Int { departedAtTide + route.duration }
    var power: Int { units.reduce(0) { $0 + ($1.key.attack + attackUpgrade) * $1.value } }
    var capacity: Int { units.reduce(0) { $0 + $1.key.carrying * $1.value } * (100 + transportBonusPercent) / 100 }
    var isValid: Bool {
        guard (0...(1_000_000 - route.duration)).contains(departedAtTide),
              (0...3).contains(attackUpgrade), [0, 20, 25, 45].contains(transportBonusPercent),
              [0.05, 0.1, 0.15, 0.2].contains(victoryLossRate), [0.35, 0.5].contains(defeatLossRate),
              units.values.allSatisfy({ (1...100).contains($0) }),
              (1...100).contains(units.values.reduce(0, +)) else { return false }
        return capacity >= TradeRoute.cargoWood
    }
}
