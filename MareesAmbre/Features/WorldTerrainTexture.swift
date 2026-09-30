import SpriteKit
import UIKit

/// Render once per world; the camera moves the texture without rebuilding geography.
@MainActor
enum WorldTerrainTexture {
    static func make(_ world: WorldMap) -> SKTexture {
        let scale: CGFloat = 10
        let side = 200
        var heights = Array(repeating: 0.0, count: 201 * 201)
        for y in 0...side {
            for x in 0...side {
                var sum = 0.0
                for dy in -2...2 {
                    for dx in -2...2 {
                        if world.terrain(at: .init(x: x + dx, y: y + dy)) != .sea {
                            sum += Double((3 - abs(dx)) * (3 - abs(dy)))
                        }
                    }
                }
                heights[y * 201 + x] = sum / 81
            }
        }
        let land = CGMutablePath()
        let coast = CGMutablePath()
        for y in 0..<side {
            for x in 0..<side {
                let corners = [(x, y), (x + 1, y), (x + 1, y + 1), (x, y + 1)]
                let values = corners.map { heights[$0.1 * 201 + $0.0] }
                let points = corners.map { CGPoint(x: CGFloat($0.0) * scale, y: CGFloat($0.1) * scale) }
                for indices in [[0, 1, 2], [0, 2, 3]] {
                    var polygon: [CGPoint] = [], crossings: [CGPoint] = []
                    for i in 0..<3 {
                        let a = indices[i], b = indices[(i + 1) % 3]
                        if values[a] >= 0.5 { polygon.append(points[a]) }
                        if (values[a] >= 0.5) != (values[b] >= 0.5) {
                            let f = (0.5 - values[a]) / (values[b] - values[a])
                            let p = CGPoint(x: points[a].x + (points[b].x - points[a].x) * f, y: points[a].y + (points[b].y - points[a].y) * f)
                            polygon.append(p); crossings.append(p)
                        }
                    }
                    if let p = polygon.first { land.move(to: p); polygon.dropFirst().forEach { land.addLine(to: $0) }; land.closeSubpath() }
                    if crossings.count == 2 { coast.move(to: crossings[0]); coast.addLine(to: crossings[1]) }
                }
            }
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 2000, height: 2000), format: format).image { renderer in
            let ctx = renderer.cgContext
            ctx.setLineJoin(.round); ctx.setLineCap(.round)
            for (width, color) in [(CGFloat(26), UIColor(red: 0.08, green: 0.55, blue: 0.60, alpha: 0.4)), (CGFloat(12), UIColor(red: 0.25, green: 0.76, blue: 0.73, alpha: 0.75))] {
                ctx.addPath(coast); ctx.setStrokeColor(color.cgColor); ctx.setLineWidth(width); ctx.strokePath()
            }
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 1, height: 5), blur: 3, color: UIColor.black.withAlphaComponent(0.6).cgColor)
            ctx.addPath(land); ctx.setFillColor(UIColor(red: 0.48, green: 0.57, blue: 0.32, alpha: 1).cgColor); ctx.fillPath()
            ctx.restoreGState()
            ctx.addPath(coast); ctx.setStrokeColor(UIColor(red: 0.85, green: 0.78, blue: 0.55, alpha: 1).cgColor); ctx.setLineWidth(5); ctx.strokePath()
            ctx.addPath(coast); ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.7).cgColor); ctx.setLineWidth(1); ctx.strokePath()
            ctx.saveGState(); ctx.addPath(land); ctx.clip()
            for y in 0..<side {
                for x in 0..<side where heights[y * 201 + x] > 0.62 {
                    let terrain = world.terrain(at: .init(x: x, y: y))
                    let px = CGFloat(x) * scale + 5, py = CGFloat(y) * scale + 5
                    if terrain == .forest {
                        ctx.setFillColor(UIColor.black.withAlphaComponent(0.17).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 3, y: py, width: 8, height: 5))
                        ctx.setFillColor(UIColor(red: 0.14, green: 0.32 + Double((x + y) % 3) * 0.04, blue: 0.21, alpha: 1).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 4, y: py - 5, width: 7, height: 8))
                        ctx.setFillColor(UIColor(red: 0.38, green: 0.52, blue: 0.29, alpha: 0.8).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 3, y: py - 5, width: 4, height: 3))
                    } else if terrain == .amber {
                        ctx.setFillColor(UIColor(red: 0.68, green: 0.65, blue: 0.51, alpha: 1).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 4, y: py - 3, width: 8, height: 6))
                        ctx.setFillColor(UIColor.systemYellow.cgColor)
                        ctx.fill(CGRect(x: px - 1, y: py - 3, width: 2, height: 5))
                    } else if (x + y) % 3 == 0 {
                        ctx.setFillColor(UIColor.white.withAlphaComponent(0.06).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px, y: py, width: 7, height: 3))
                    }
                }
            }
            ctx.restoreGState()
        }
        return SKTexture(image: image)
    }
}
