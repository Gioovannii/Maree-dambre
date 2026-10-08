import Foundation

enum ResourceKind: String, CaseIterable, Identifiable {
    case wood, amber, provisions
    var id: Self { self }
    var name: String {
        switch self {
        case .wood: String(localized: "domain.resource_kind.wood", defaultValue: "Bois")
        case .amber: String(localized: "domain.resource_kind.amber", defaultValue: "Ambre")
        case .provisions: String(localized: "domain.resource_kind.provisions", defaultValue: "Vivres")
        }
    }
    var symbol: String {
        switch self {
        case .wood: "tree.fill"
        case .amber: "sparkles"
        case .provisions: "basket.fill"
        }
    }
    // Amber is worth twice as much; the market keeps half of the exchange value.
    var tradeValue: Int { self == .amber ? 2 : 1 }
}

extension Resources {
    subscript(kind: ResourceKind) -> Int {
        get {
            switch kind {
            case .wood: wood
            case .amber: amber
            case .provisions: provisions
            }
        }
        set {
            switch kind {
            case .wood: wood = newValue
            case .amber: amber = newValue
            case .provisions: provisions = newValue
            }
        }
    }
}
