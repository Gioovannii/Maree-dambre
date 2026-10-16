import SwiftUI

/// Artwork-space coastlines, kept separate from the interactive plot layout.
struct CoastalSeaMask: Shape {
    var mode: VillageMapMode = .resourceFields

    func path(in rect: CGRect) -> Path {
        if mode == .townCenter { return townSea(in: rect) }
        let contours: [[CGPoint]] = [
            [CGPoint(x: 0, y: 0), CGPoint(x: 613, y: 0), CGPoint(x: 606, y: 40),
             CGPoint(x: 614, y: 121), CGPoint(x: 639, y: 143), CGPoint(x: 662, y: 156),
             CGPoint(x: 689, y: 177), CGPoint(x: 671, y: 194), CGPoint(x: 628, y: 196),
             CGPoint(x: 592, y: 211), CGPoint(x: 541, y: 238), CGPoint(x: 476, y: 249),
             CGPoint(x: 406, y: 232), CGPoint(x: 344, y: 210), CGPoint(x: 254, y: 188),
             CGPoint(x: 192, y: 202), CGPoint(x: 143, y: 228), CGPoint(x: 88, y: 247),
             CGPoint(x: 0, y: 270)],
            [CGPoint(x: 0, y: 1274), CGPoint(x: 33, y: 1281), CGPoint(x: 62, y: 1302),
             CGPoint(x: 96, y: 1298), CGPoint(x: 99, y: 1315), CGPoint(x: 75, y: 1329),
             CGPoint(x: 0, y: 1358)],
            [CGPoint(x: 432, y: 1308), CGPoint(x: 466, y: 1339), CGPoint(x: 515, y: 1364),
             CGPoint(x: 492, y: 1404), CGPoint(x: 505, y: 1435), CGPoint(x: 576, y: 1454),
             CGPoint(x: 624, y: 1504), CGPoint(x: 656, y: 1513), CGPoint(x: 698, y: 1504),
             CGPoint(x: 753, y: 1525), CGPoint(x: 814, y: 1563), CGPoint(x: 887, y: 1588),
             CGPoint(x: 887, y: 1774), CGPoint(x: 278, y: 1774), CGPoint(x: 287, y: 1534),
             CGPoint(x: 319, y: 1530), CGPoint(x: 301, y: 1594), CGPoint(x: 254, y: 1618),
             CGPoint(x: 212, y: 1583), CGPoint(x: 240, y: 1568), CGPoint(x: 396, y: 1493),
             CGPoint(x: 376, y: 1434), CGPoint(x: 418, y: 1390), CGPoint(x: 414, y: 1361)]
        ]
        var path = Path()
        for points in contours {
            path.addLines(points.map { CGPoint(x: rect.minX + $0.x / 887 * rect.width,
                                               y: rect.minY + $0.y / 1774 * rect.height) })
            path.closeSubpath()
        }
        // The sailboat stays anchored while the surrounding water moves.
        let boat = CGRect(x: rect.minX + 0.02 * rect.width, y: rect.minY + 0.06 * rect.height,
                          width: 0.14 * rect.width, height: 0.07 * rect.height)
        var cutout = Path(rect)
        cutout.addRect(boat)
        return path.intersection(cutout, eoFill: true)
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
