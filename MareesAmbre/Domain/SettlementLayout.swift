import Foundation

enum VillageMapMode: String, CaseIterable, Identifiable, Sendable {
    case resourceFields
    case townCenter

    var id: Self { self }

    var assetName: String {
        switch self {
        case .resourceFields: "DomaineAmbreVivant"
        case .townCenter: "CentreAmbreVivant"
        }
    }

    var title: String {
        switch self {
        case .resourceFields: String(localized: "domain.settlement_layout.coastal_resources", defaultValue: "Ressources côtières")
        case .townCenter: String(localized: "domain.settlement_layout.amber_town_center", defaultValue: "Centre-ville d’Ambre")
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
            // Follow the estate's clearings rather than imposing a grid on the terrain.
            let clearings: [CGPoint] = [
                CGPoint(x: 0.245, y: 0.205), CGPoint(x: 0.69, y: 0.217),
                CGPoint(x: 0.78, y: 0.335), CGPoint(x: 0.225, y: 0.325),
                CGPoint(x: 0.825, y: 0.485), CGPoint(x: 0.175, y: 0.465),
                CGPoint(x: 0.50, y: 0.405), CGPoint(x: 0.75, y: 0.61),
                CGPoint(x: 0.245, y: 0.63), CGPoint(x: 0.84, y: 0.71)
            ]
            guard clearings.indices.contains(plot) else { return CGPoint(x: 0.5, y: 0.5) }
            return clearings[plot]
        }
        if plot == 12 { return CGPoint(x: 0.50, y: 0.345) }
        if plot == SettlementLayout.expeditionQuayPlot { return CGPoint(x: 0.69, y: 0.785) }
        let lots = [10, 11, 13, 14, 15, 16, 17, 18, 19, 22, 23]
        guard let index = lots.firstIndex(of: plot) else { return CGPoint(x: 0.5, y: 0.5) }
        let points: [CGPoint] = [
            CGPoint(x: 0.25, y: 0.268), CGPoint(x: 0.50, y: 0.232), CGPoint(x: 0.75, y: 0.268),
            CGPoint(x: 0.16, y: 0.355), CGPoint(x: 0.84, y: 0.355), CGPoint(x: 0.28, y: 0.452),
            CGPoint(x: 0.73, y: 0.452), CGPoint(x: 0.31, y: 0.56), CGPoint(x: 0.69, y: 0.56),
            CGPoint(x: 0.30, y: 0.665), CGPoint(x: 0.70, y: 0.665)
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
    static let expeditionQuayPlot = 23
    static func position(for plot: Int) -> SettlementPosition {
        let column = plot % 5
        let row = plot / 5
        return SettlementPosition(
            east: Double(column - 2) / 2,
            north: Double(2 - row) / 2
        )
    }
}
