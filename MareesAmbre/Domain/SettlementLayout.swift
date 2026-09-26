import Foundation

enum VillageMapMode: String, CaseIterable, Identifiable, Sendable {
    case resourceFields
    case townCenter

    var id: Self { self }

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
        case .townCenter: 12
        }
    }

    var focus: SettlementPosition {
        switch self {
        case .resourceFields: SettlementPosition(east: 0, north: 0.75)
        case .townCenter: SettlementPosition(east: 0, north: 0)
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
