import Foundation

enum VillageMapMode: String, CaseIterable, Identifiable, Sendable {
    case resourceFields
    case townCenter

    var id: Self { self }

    var assetName: String {
        switch self {
        case .resourceFields: "RessourcesAutourVillage"
        case .townCenter: "CentreVilleClair"
        }
    }

    var title: String {
        switch self {
        case .resourceFields: "Ressources"
        case .townCenter: "Centre-ville"
        }
    }

    var symbol: String {
        switch self {
        case .resourceFields: "leaf.fill"
        case .townCenter: "building.2.fill"
        }
    }

    var slots: [Int] {
        switch self {
        case .resourceFields: Array(0..<10)
        case .townCenter: Array(10..<20) + [22, 23]
        }
    }

    var initialPlot: Int {
        switch self {
        case .resourceFields: 2
        case .townCenter: 13
        }
    }

    func mapPoint(for plot: Int) -> CGPoint {
        switch self {
        case .resourceFields:
            return switch plot {
            case 0: CGPoint(x: 0.16, y: 0.17)
            case 1: CGPoint(x: 0.13, y: 0.34)
            case 2: CGPoint(x: 0.45, y: 0.20)
            case 3: CGPoint(x: 0.73, y: 0.30)
            case 4: CGPoint(x: 0.88, y: 0.41)
            case 5: CGPoint(x: 0.14, y: 0.50)
            case 6: CGPoint(x: 0.17, y: 0.68)
            case 7: CGPoint(x: 0.42, y: 0.78)
            case 8: CGPoint(x: 0.64, y: 0.80)
            case 9: CGPoint(x: 0.87, y: 0.56)
            default: CGPoint(x: 0.50, y: 0.50)
            }
        case .townCenter:
            return switch plot {
            // Equal-size lots form a clear ring around the central hall.
            // Keeping these anchors regular makes every future building feel
            // like it owns the same amount of space.
            case 10: CGPoint(x: 0.14, y: 0.24)
            case 11: CGPoint(x: 0.37, y: 0.20)
            case 12: CGPoint(x: 0.50, y: 0.50)
            case 13: CGPoint(x: 0.63, y: 0.20)
            case 14: CGPoint(x: 0.86, y: 0.24)
            case 15: CGPoint(x: 0.12, y: 0.45)
            case 16: CGPoint(x: 0.12, y: 0.66)
            case 17: CGPoint(x: 0.88, y: 0.45)
            case 18: CGPoint(x: 0.88, y: 0.66)
            case 19: CGPoint(x: 0.14, y: 0.80)
            case 22: CGPoint(x: 0.37, y: 0.82)
            case 23: CGPoint(x: 0.63, y: 0.82)
            default: CGPoint(x: 0.50, y: 0.50)
            }
        }
    }

    var focus: SettlementPosition {
        switch self {
        case .resourceFields: SettlementPosition(east: 0, north: 0)
        case .townCenter: SettlementPosition(east: 1.0 / 6.0, north: 0)
        }
    }

    func contains(_ plot: Int) -> Bool { slots.contains(plot) }

    func slotNumber(for plot: Int) -> Int? {
        slots.firstIndex(of: plot).map { $0 + 1 }
    }
}

/// Shared ground-plane coordinates for scene renderers. A 2D view projects
/// east/north to screen points; a future RealityKit view can map them to x/z.
struct SettlementPosition: Equatable, Sendable {
    let east: Double
    let north: Double
}

enum SettlementLayout {
    static func position(for plot: Int) -> SettlementPosition {
        let column = plot % 5
        let row = plot / 5
        return SettlementPosition(
            east: Double(column - 2) / 2,
            north: Double(2 - row) / 2
        )
    }
}
