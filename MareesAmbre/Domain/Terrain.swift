enum Terrain: String, Codable, Sendable {
    case sea, meadow, forest, amber
    var name: String {
        switch self {
        case .sea: String(localized: "domain.terrain.sea", defaultValue: "Mer")
        case .meadow: String(localized: "domain.terrain.meadow", defaultValue: "Prairie")
        case .forest: String(localized: "domain.terrain.forest", defaultValue: "Forêt")
        case .amber: String(localized: "domain.terrain.amber_deposit", defaultValue: "Gisement d’ambre")
        }
    }
}
