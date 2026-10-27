import Foundation

enum TradeRoute: String, Codable, CaseIterable, Identifiable {
    case sheltered, crossing

    var id: Self { self }
    var duration: Int { self == .sheltered ? 3 : 2 }
    var travelDuration: TimeInterval { TimeInterval(duration) * 600 }
    static let restockDuration: TimeInterval = 3600
    var enemyPower: Int { self == .sheltered ? 0 : 24 }
    var amberReward: Int { self == .sheltered ? 18 : 26 }
    static let cargoWood = 20
    static let travelProvisions = 5
    static let restockTides = 6

    var name: String {
        switch self {
        case .sheltered: String(localized: "screen.commerce.sheltered", defaultValue: "La route des lagunes")
        case .crossing: String(localized: "screen.commerce.crossing", defaultValue: "La passe des corsaires")
        }
    }
    static var partner: String {
        String(localized: "screen.commerce.partner", defaultValue: "Comptoir des Roseaux")
    }
}
