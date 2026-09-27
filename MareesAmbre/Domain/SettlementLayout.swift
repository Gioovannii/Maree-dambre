import Foundation

enum VillageMapMode: String, CaseIterable, Identifiable, Sendable {
    case resourceFields
    case townCenter

    var id: Self { self }

    var assetName: String {
        switch self {
        case .resourceFields: "ChampsDuPortClair"
        case .townCenter: "CentreVilleClair"
        }
    }

    var title: String {
        switch self {
        case .resourceFields: "Champs du Port"
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
            let x: [CGFloat] = [0.13, 0.34, 0.55, 0.77, 0.92]
            return CGPoint(x: x[plot % 5], y: plot < 5 ? 0.36 : 0.65)
        case .townCenter:
            return switch plot {
            case 10: CGPoint(x: 0.07, y: 0.27)
            case 11: CGPoint(x: 0.25, y: 0.27)
            case 12: CGPoint(x: 0.50, y: 0.35)
            case 13: CGPoint(x: 0.75, y: 0.27)
            case 14: CGPoint(x: 0.94, y: 0.34)
            case 15: CGPoint(x: 0.13, y: 0.53)
            case 16: CGPoint(x: 0.37, y: 0.57)
            case 17: CGPoint(x: 0.63, y: 0.57)
            case 18: CGPoint(x: 0.87, y: 0.53)
            case 19: CGPoint(x: 0.95, y: 0.68)
            case 22: CGPoint(x: 0.22, y: 0.78)
            case 23: CGPoint(x: 0.78, y: 0.78)
            default: CGPoint(x: 0.50, y: 0.50)
            }
        }
    }

    var focus: SettlementPosition {
        switch self {
        case .resourceFields: SettlementPosition(east: 0, north: 0.75)
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
