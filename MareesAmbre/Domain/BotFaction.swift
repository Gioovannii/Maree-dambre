struct BotFaction: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let capital: TileCoordinate
    var territory: [TileCoordinate]
    var level = 1

    static var starting: [BotFaction] {
        [BotFaction(id: 0, name: "Les Sauniers", capital: .init(x: 108, y: 96), territory: [.init(x: 108, y: 96)]),
         BotFaction(id: 1, name: "La Garde de Nacre", capital: .init(x: 92, y: 108), territory: [.init(x: 92, y: 108)]),
         BotFaction(id: 2, name: "Le Pacte des Roseaux", capital: .init(x: 116, y: 110), territory: [.init(x: 116, y: 110)])]
    }
}
