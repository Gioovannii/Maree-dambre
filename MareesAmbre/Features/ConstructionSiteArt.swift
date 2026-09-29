import SwiftUI

/// Foundations, rising masonry and timber scaffolding share the map's isometric perspective.
struct ConstructionSiteArt: View {
    let kind: BuildingKind
    let progress: Double

    var body: some View {
        ZStack {
            masonry
            if progress >= 0.3 {
                BuildingArt(kind: kind)
                    .mask(alignment: .bottom) {
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(height: geometry.size.height * min(1, 0.35 + (progress - 0.3) * 0.95))
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
            }
            scaffold
        }
        .accessibilityHidden(true)
    }

    private var masonry: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let rise = 0.10 + 0.25 * min(1, max(0, progress))
            let timber = Color(red: 0.58, green: 0.36, blue: 0.18)
            func point(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * w, y: y * h) }
            func polygon(_ points: [CGPoint], _ color: Color) {
                var path = Path()
                path.addLines(points)
                path.closeSubpath()
                context.fill(path, with: .color(color))
            }
            func beam(_ from: CGPoint, _ to: CGPoint, width: CGFloat = 2) {
                var path = Path()
                path.move(to: from)
                path.addLine(to: to)
                context.stroke(path, with: .color(timber), style: StrokeStyle(lineWidth: width, lineCap: .round))
            }
            context.fill(Path(ellipseIn: CGRect(x: w * 0.06, y: h * 0.69, width: w * 0.88, height: h * 0.25)), with: .color(.black.opacity(0.25)))
            polygon([point(0.08, 0.64), point(0.48, 0.48), point(0.93, 0.68), point(0.52, 0.90)], Color(red: 0.48, green: 0.40, blue: 0.29))
            polygon([point(0.18, 0.63), point(0.48, 0.50), point(0.83, 0.66), point(0.52, 0.81)], Color(red: 0.74, green: 0.70, blue: 0.56))
            polygon([point(0.18, 0.63), point(0.18, 0.63 - rise), point(0.52, 0.81 - rise), point(0.52, 0.81)], Color(red: 0.83, green: 0.76, blue: 0.60))
            polygon([point(0.52, 0.81), point(0.52, 0.81 - rise), point(0.83, 0.66 - rise), point(0.83, 0.66)], Color(red: 0.60, green: 0.57, blue: 0.46))
            // Mortar courses remain visible during the foundation stage.
            for row in 1...3 {
                let y = Double(row) * rise / 4
                beam(point(0.19, 0.63 - y), point(0.51, 0.80 - y), width: 0.8)
            }
        }
        .opacity(progress < 0.3 ? 1 : max(0, 1 - (progress - 0.3) * 5))
    }

    private var scaffold: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let timber = Color(red: 0.58, green: 0.36, blue: 0.18)
            func point(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * w, y: y * h) }
            func beam(_ from: CGPoint, _ to: CGPoint, width: CGFloat = 2) {
                var path = Path()
                path.move(to: from)
                path.addLine(to: to)
                context.stroke(path, with: .color(timber), style: StrokeStyle(lineWidth: width, lineCap: .round))
            }
            // Scaffolding stays on one side so the actual building remains legible.
            for x in [0.48, 0.89] {
                let bottom = x == 0.48 ? 0.87 : 0.72
                beam(point(x, bottom), point(x, bottom - 0.59), width: max(2, w * 0.028))
            }
            for offset in [0.0, 0.22] {
                beam(point(0.48, 0.47 + offset), point(0.89, 0.30 + offset), width: max(2, w * 0.027))
            }
            beam(point(0.48, 0.69), point(0.89, 0.30))
            // Stacked planks and amber-colored canvas distinguish the active site.
            for row in 0..<3 {
                let y = 0.85 + Double(row) * 0.025
                beam(point(0.66, y), point(0.92, y - 0.11), width: max(2, w * 0.025))
            }
        }
        .accessibilityHidden(true)
    }
}
