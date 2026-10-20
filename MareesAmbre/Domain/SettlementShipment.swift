import Foundation

/// A local supply route. Troops return independently of cargo awaiting storage.
struct SettlementShipment: Codable, Equatable {
    let destination: TileCoordinate
    let cargo: Resources
    let units: [ArmyUnit: Int]
    let transportBonusPercent: Int
    let departedAt: Date
    let arrivesAt: Date
    let returnsAt: Date
    var unloaded = Resources(wood: 0, amber: 0, provisions: 0)
    var escortReturned = false

    var capacity: Int {
        units.reduce(0) { $0 + $1.key.carrying * $1.value } * (100 + transportBonusPercent) / 100
    }
    var cargoCount: Int { cargo.wood + cargo.amber + cargo.provisions }
    var remaining: Resources {
        Resources(wood: cargo.wood - unloaded.wood, amber: cargo.amber - unloaded.amber,
                  provisions: cargo.provisions - unloaded.provisions)
    }
    var isComplete: Bool { unloaded == cargo && escortReturned }
    var isValid: Bool {
        guard destination.isValid,
              [departedAt, arrivesAt, returnsAt].allSatisfy({ $0 >= .distantPast && $0 <= .distantFuture }),
              arrivesAt > departedAt, returnsAt > arrivesAt,
              returnsAt.timeIntervalSince(departedAt) <= 86_400,
              (0...110).contains(transportBonusPercent),
              !units.isEmpty, units.values.allSatisfy({ (1...100).contains($0) }),
              units.values.reduce(0, +) <= 100,
              [cargo.wood, cargo.amber, cargo.provisions].allSatisfy({ (0...999_999).contains($0) }),
              (1...capacity).contains(cargoCount) else { return false }
        return (0...cargo.wood).contains(unloaded.wood) && (0...cargo.amber).contains(unloaded.amber)
            && (0...cargo.provisions).contains(unloaded.provisions)
    }
}
