enum Terrain: String, Codable, Sendable {
    case sea, meadow, forest, amber
    var name: String {
        switch self {
        case .sea: "Mer"
        case .meadow: "Prairie"
        case .forest: "Forêt"
        case .amber: "Gisement d’ambre"
        }
    }
}
