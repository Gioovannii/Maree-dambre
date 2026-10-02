enum Terrain: String, Codable, Sendable {
    case sea, meadow, forest, amber
    var name: String {
        switch self {
        case .sea: L10n.text("Mer", "Sea")
        case .meadow: L10n.text("Prairie", "Meadow")
        case .forest: L10n.text("Forêt", "Forest")
        case .amber: L10n.text("Gisement d’ambre", "Amber Deposit")
        }
    }
}
