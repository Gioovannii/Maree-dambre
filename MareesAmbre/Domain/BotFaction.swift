struct BotFaction: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let capital: TileCoordinate
    var territory: [TileCoordinate]
    var level = 1

    var displayName: String {
        switch id % 3 {
        case 0: String(localized: "domain.bot_faction.the_salt_traders", defaultValue: "Les Sauniers")
        case 1: String(localized: "domain.bot_faction.the_pearl_guard", defaultValue: "La Garde de Nacre")
        default: String(localized: "domain.bot_faction.the_reed_pact", defaultValue: "Le Pacte des Roseaux")
        }
    }

    var distanceFromHome: Int {
        abs(capital.x - TileCoordinate.home.x) + abs(capital.y - TileCoordinate.home.y)
    }

    var maximumLevel: Int {
        switch distanceFromHome {
        case 0...26: 5
        case 27...30: 7
        case 31...70: 9
        default: 10
        }
    }

    static let maximumStartingID = 11

    func pseudonym(seed: Int) -> String {
        let names = ["Elyan", "Maëlys", "Neris", "Kaëlor", "Sélène", "Orin",
                     "Liora", "Taren", "Mirel", "Aveline", "Naël", "Ysée"]
        let offset = Int(UInt64(truncatingIfNeeded: seed) % UInt64(names.count))
        return names[(offset + id) % names.count]
    }

    static var starting: [BotFaction] {
        // Keep the original three coordinates stable for existing worlds.
        let locations = [(108, 96), (92, 108), (116, 110),
                         (130, 100), (100, 70), (70, 100),
                         (100, 170), (170, 100), (100, 30),
                         (190, 100), (100, 190), (10, 100)]
        return locations.enumerated().map { id, point in
            let capital = TileCoordinate(x: point.0, y: point.1)
            let level = id < 3 ? 1 : id < 6 ? 3 : id < 9 ? 5 : 7
            return BotFaction(id: id, name: "Voisin \(id + 1)", capital: capital, territory: [capital], level: level)
        }
    }
}
