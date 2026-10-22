import Foundation

/// Coordinates registered to the tablet estate illustration, independent of phone artwork.
enum TabletEstateLayout {
    static func point(for plot: Int) -> CGPoint {
        let points: [CGPoint] = [
            .init(x: 0.18, y: 0.24), .init(x: 0.50, y: 0.24),
            .init(x: 0.82, y: 0.24), .init(x: 0.18, y: 0.43),
            .init(x: 0.82, y: 0.43), .init(x: 0.15, y: 0.65),
            .init(x: 0.50, y: 0.43), .init(x: 0.62, y: 0.65),
            .init(x: 0.38, y: 0.65), .init(x: 0.85, y: 0.65)
        ]
        return points.indices.contains(plot) ? points[plot] : .init(x: 0.5, y: 0.5)
    }

    static let routes: [[CGPoint]] = [
        [.init(x: 0.08, y: 0.32), .init(x: 0.48, y: 0.32), .init(x: 0.92, y: 0.32)],
        [.init(x: 0.08, y: 0.52), .init(x: 0.48, y: 0.52), .init(x: 0.92, y: 0.52)]
    ]
}
