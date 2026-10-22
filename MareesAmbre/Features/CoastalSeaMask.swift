import SwiftUI

/// Artwork-space coastlines, kept separate from the interactive plot layout.
struct CoastalSeaMask: Shape {
    var mode: VillageMapMode = .resourceFields

    func path(in rect: CGRect) -> Path {
        if mode == .townCenter { return townSea(in: rect) }
        // Conservative open-water regions for the central-estate artwork.
        // Keep shore structures and both boats outside the resampling mask.
        var water = Path()
        water.addRect(CGRect(x: rect.minX + rect.width * 0.25,
                             y: rect.minY + rect.height * 0.06,
                             width: rect.width * 0.35, height: rect.height * 0.14))
        water.addRect(CGRect(x: rect.minX + rect.width * 0.25,
                             y: rect.minY + rect.height * 0.84,
                             width: rect.width * 0.55, height: rect.height * 0.10))
        return water
    }
    private func townSea(in rect: CGRect) -> Path {
        let contours: [[CGPoint]] = [
            [CGPoint(x: 0.55, y: 0.097), CGPoint(x: 0.66, y: 0.092), CGPoint(x: 0.80, y: 0.083),
             CGPoint(x: 1, y: 0.075), CGPoint(x: 1, y: 0.14), CGPoint(x: 0.88, y: 0.135),
             CGPoint(x: 0.77, y: 0.126), CGPoint(x: 0.66, y: 0.115), CGPoint(x: 0.55, y: 0.108)],
            [CGPoint(x: 0.15, y: 0.735), CGPoint(x: 0.32, y: 0.752), CGPoint(x: 0.50, y: 0.77),
             CGPoint(x: 0.71, y: 0.79), CGPoint(x: 0.87, y: 0.795), CGPoint(x: 1, y: 0.81),
             CGPoint(x: 1, y: 1), CGPoint(x: 0.47, y: 1), CGPoint(x: 0.43, y: 0.97),
             CGPoint(x: 0.41, y: 0.93), CGPoint(x: 0.34, y: 0.89), CGPoint(x: 0.27, y: 0.86),
             CGPoint(x: 0.19, y: 0.84), CGPoint(x: 0.11, y: 0.82), CGPoint(x: 0.08, y: 0.77)]
        ]
        var path = Path()
        for points in contours {
            path.addLines(points.map { CGPoint(x: rect.minX + $0.x * rect.width,
                                               y: rect.minY + $0.y * rect.height) })
            path.closeSubpath()
        }
        return path
    }

}
