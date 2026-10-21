import Foundation

/// Battle facts are stored independently from their presentation so a saved report
/// can be displayed in the app's current language after relaunch.
struct RaidReport: Codable, Equatable {
    var targetName: String
    var attackPower: Int
    var defensePower: Int
    var unitsSent: [ArmyUnit: Int]
    var losses: [ArmyUnit: Int]
    var stolen: Resources
    var enemyUnits: [ArmyUnit: Int]? = nil
    var enemyFortifications: Int? = nil
    var includesHero: Bool? = nil

    var won: Bool { attackPower > defensePower }
    var lossCount: Int { losses.values.reduce(0, +) }
    var returnedCount: Int { unitsSent.values.reduce(0, +) - lossCount }

    var isValid: Bool {
        (1...80).contains(targetName.count)
            && RaidOrder.validEnemySnapshot(units: enemyUnits, fortifications: enemyFortifications, defense: defensePower)
            && (0...3_000).contains(attackPower)
            && (0...3_000).contains(defensePower)
            && !unitsSent.isEmpty
            && unitsSent.values.allSatisfy { (1...100).contains($0) }
            && unitsSent.values.reduce(0, +) <= 100
            && losses.allSatisfy { unitsSent[$0.key, default: 0] >= $0.value && (0...100).contains($0.value) }
            && lossCount <= unitsSent.values.reduce(0, +)
            && [stolen.wood, stolen.amber, stolen.provisions].allSatisfy { (0...270).contains($0) }
            && (won || stolen == Resources(wood: 0, amber: 0, provisions: 0))
    }
}
