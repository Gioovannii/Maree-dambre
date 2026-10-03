enum ResourceSiteKind: String, CaseIterable, Identifiable, Sendable {
    case woodland, cropland, amberVein
    static let maximumLevel = 10

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
        case .woodland: String(localized: "domain.resource_site_kind.cliff_woodland", defaultValue: "Bois des falaises")
        case .cropland: String(localized: "domain.resource_site_kind.farmland", defaultValue: "Terres cultivables")
        case .amberVein: String(localized: "domain.resource_site_kind.amber_vein", defaultValue: "Veine d’ambre")
        }
    }

    var imageAssetName: String {
        switch self {
        case .woodland: "ParcelleBois"
        case .cropland: "ParcelleVivres"
        case .amberVein: "ParcelleAmbre"
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
        case .woodland: String(localized: "domain.resource_site_kind.wood", defaultValue: "bois")
        case .cropland: String(localized: "domain.resource_site_kind.food", defaultValue: "vivres")
        case .amberVein: String(localized: "domain.resource_site_kind.amber", defaultValue: "ambre")
        }
    }

    func cost(for nextLevel: Int) -> Resources {
        switch self {
        case .woodland: Resources(wood: 5 * nextLevel, amber: 0, provisions: nextLevel / 3)
        case .cropland: Resources(wood: 4 * nextLevel, amber: 0, provisions: 2 * nextLevel)
        case .amberVein: Resources(wood: 7 * nextLevel, amber: 2 * nextLevel, provisions: 3 * nextLevel)
        }
    }
}
