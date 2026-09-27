enum ResourceSiteKind: String, CaseIterable, Identifiable, Sendable {
    case woodland, cropland, amberVein

    var id: Self { self }

    static func at(_ plot: Int) -> Self? {
        guard VillageMapMode.resourceFields.contains(plot) else { return nil }
        return switch VillageState.ground(at: plot) {
        case .forest: .woodland
        case .meadow: .cropland
        case .amber: .amberVein
        case .sea: nil
        }
    }

    var name: String {
        switch self {
        case .woodland: "Bois des falaises"
        case .cropland: "Terres cultivables"
        case .amberVein: "Veine d’ambre"
        }
    }

    var symbol: String {
        switch self {
        case .woodland: "tree.fill"
        case .cropland: "leaf.fill"
        case .amberVein: "sparkles"
        }
    }

    var yieldPerLevel: Resources {
        switch self {
        case .woodland: Resources(wood: 8, amber: 0, provisions: 0)
        case .cropland: Resources(wood: 0, amber: 0, provisions: 8)
        case .amberVein: Resources(wood: 0, amber: 4, provisions: 0)
        }
    }

    var yieldLabel: String {
        switch self {
        case .woodland: "bois"
        case .cropland: "vivres"
        case .amberVein: "ambre"
        }
    }

    func cost(for nextLevel: Int) -> Resources {
        switch self {
        case .woodland: Resources(wood: 25 * nextLevel, amber: 5 * nextLevel, provisions: 10 * nextLevel)
        case .cropland: Resources(wood: 20 * nextLevel, amber: 0, provisions: 5 * nextLevel)
        case .amberVein: Resources(wood: 35 * nextLevel, amber: 10 * nextLevel, provisions: 15 * nextLevel)
        }
    }
}
