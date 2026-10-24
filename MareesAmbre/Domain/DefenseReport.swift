import Foundation

/// Store battle facts rather than a translated sentence, so reports follow app language.
struct DefenseReport: Codable, Equatable {
    var tide: Int
    var enemyPower: Int
    var garrisonPower: Int
    var fortificationPower: Int
    var won: Bool
    var losses: [ArmyUnit: Int]
    var stolen: Resources
    var attackerName: String? = nil

    var lossCount: Int { losses.values.reduce(0, +) }
    var isValid: Bool {
        (2...1_000_000).contains(tide) && (24...252).contains(enemyPower)
            && (0...(ArmyState.maximumTroops * 30)).contains(garrisonPower) && (0...271).contains(fortificationPower)
            && fortificationPower <= garrisonPower && won == (garrisonPower >= enemyPower)
            && losses.values.allSatisfy { (1...ArmyState.maximumTroops).contains($0) } && lossCount <= ArmyState.maximumTroops
            && [stolen.wood, stolen.amber, stolen.provisions].allSatisfy { (0...90).contains($0) }
            && (!won || stolen == Resources(wood: 0, amber: 0, provisions: 0))
    }
}
