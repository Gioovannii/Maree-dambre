import SwiftUI

struct IslandSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGPoint] = [.init(x: 0.03, y: 0.48), .init(x: 0.20, y: 0.23),
            .init(x: 0.41, y: 0.16), .init(x: 0.58, y: 0.02), .init(x: 0.72, y: 0.22),
            .init(x: 0.96, y: 0.34), .init(x: 0.87, y: 0.61), .init(x: 0.65, y: 0.76),
            .init(x: 0.49, y: 0.98), .init(x: 0.22, y: 0.83)]
        return Path { path in
            path.addLines(points.map { CGPoint(x: $0.x * rect.width, y: $0.y * rect.height) })
            path.closeSubpath()
        }
    }
}
