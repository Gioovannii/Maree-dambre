import Foundation

enum VillageMapMode: String, CaseIterable, Identifiable, Sendable {
    case resourceFields
    case townCenter

    var id: Self { self }

    var assetName: String {
        switch self {
        case .resourceFields: "ChampsSobres"
        case .townCenter: "CentrePave"
        }
    }

    var title: String {
        switch self {
        case .resourceFields: "Ressources côtières"
        case .townCenter: "Centre-ville d’Ambre"
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

    // Legacy lots remain addressable so existing buildings and jobs are preserved.
    var defaultVisibleSlots: [Int] {
        self == .townCenter ? slots : slots
    }

    func mapPoint(for plot: Int) -> CGPoint {
        if self == .resourceFields {
            let column = plot == 9 ? 1 : plot % 3
            return CGPoint(x: 0.22 + Double(column) * 0.28, y: 0.28 + Double(plot / 3) * 0.13)
        }
        if plot == 12 { return CGPoint(x: 0.5, y: 0.22) }
        let lots = [10, 11, 13, 14, 15, 16, 17, 18, 19, 22, 23]
        guard let index = lots.firstIndex(of: plot) else { return CGPoint(x: 0.5, y: 0.5) }
        let points: [CGPoint] = [
            CGPoint(x: 0.20, y: 0.32), CGPoint(x: 0.50, y: 0.37), CGPoint(x: 0.80, y: 0.32),
            CGPoint(x: 0.20, y: 0.46), CGPoint(x: 0.50, y: 0.50), CGPoint(x: 0.80, y: 0.46),
            CGPoint(x: 0.20, y: 0.61), CGPoint(x: 0.50, y: 0.66), CGPoint(x: 0.80, y: 0.61),
            CGPoint(x: 0.30, y: 0.76), CGPoint(x: 0.70, y: 0.76)
        ]
        return points[index]
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
