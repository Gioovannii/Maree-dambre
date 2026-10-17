import SpriteKit
import UIKit
import os

/// Render once per world; the camera moves the texture without rebuilding geography.
@MainActor
enum WorldTerrainTexture {
    private static var cachedSeed: Int?
    private static var cachedTask: Task<UIImage, Never>?
    private static var cachedTexture: SKTexture?

    static func make(_ world: WorldMap) async -> SKTexture {
        if cachedSeed == world.seed, let cachedTexture { return cachedTexture }
        if cachedSeed != world.seed || cachedTask == nil {
            cachedSeed = world.seed
            cachedTexture = nil
            let sprites = WorldTerrainArtwork.sprites()
            let ground = WorldTerrainArtwork.ground()
            cachedTask = Task.detached(priority: .userInitiated) { render(world, sprites: sprites, ground: ground) }
        }
        let image = await cachedTask!.value
        let texture = SKTexture(image: image)
        if cachedSeed == world.seed {
            cachedTexture = texture
            cachedTask = nil
        }
        return texture
    }

    nonisolated private static func render(_ world: WorldMap, sprites: [CGImage], ground: CGImage?) -> UIImage {
        let started = ContinuousClock.now
        let scale: CGFloat = 16
        let side = 200
        var heights = Array(repeating: 0.0, count: 201 * 201)
        for y in 0...side {
            for x in 0...side {
                var sum = 0.0
                for dy in -3...3 {
                    for dx in -3...3 {
                        if world.terrain(at: .init(x: x + dx, y: y + dy)) != .sea {
                            sum += Double((4 - abs(dx)) * (4 - abs(dy)))
                        }
                    }
                }
                // Small, continuous variations soften the old rectangular shores.
                let coastVariation = sin(Double(x) * 0.71 + sin(Double(y) * 0.43))
                    * cos(Double(y) * 0.61 + Double(world.seed % 31)) * 0.055
                heights[y * 201 + x] = sum / 256 + coastVariation
            }
        }
        let land = CGMutablePath()
        var segments: [(CGPoint, CGPoint)] = []
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
                    if crossings.count == 2 { segments.append((crossings[0], crossings[1])) }
                }
            }
        }
        let coast = CoastlinePath.make(segments)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let extent = CGFloat(side) * scale
        let image = UIGraphicsImageRenderer(size: CGSize(width: extent, height: extent), format: format).image { renderer in
            let ctx = renderer.cgContext
            ctx.setLineJoin(.round); ctx.setLineCap(.round)
            for band in stride(from: 12, through: 1, by: -1) {
                ctx.addPath(coast)
                ctx.setStrokeColor(UIColor(red: 0.35, green: 0.82, blue: 0.75, alpha: 0.055).cgColor)
                ctx.setLineWidth(scale * CGFloat(band) * 0.26)
                ctx.strokePath()
            }
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 2, height: 7), blur: 6, color: UIColor(red: 0.01, green: 0.18, blue: 0.22, alpha: 0.5).cgColor)
            ctx.addPath(land); ctx.setFillColor(UIColor(red: 0.88, green: 0.79, blue: 0.59, alpha: 1).cgColor); ctx.fillPath()
            ctx.restoreGState()
            ctx.addPath(coast); ctx.setStrokeColor(UIColor(red: 0.94, green: 0.91, blue: 0.77, alpha: 0.9).cgColor); ctx.setLineWidth(scale * 0.6); ctx.strokePath()
            ctx.saveGState(); ctx.addPath(land); ctx.clip()
            WorldTerrainArtwork.meadow(in: ctx, side: extent, seed: world.seed, ground: ground)
            // Limestone faces, warm sand and a sunlit lip give the coast its depth.
            for (width, color) in [(scale * 0.8, UIColor(red: 0.57, green: 0.54, blue: 0.36, alpha: 0.6)),
                                   (scale * 0.55, UIColor(red: 0.85, green: 0.76, blue: 0.54, alpha: 1)),
                                   (scale * 0.16, UIColor(red: 1, green: 0.94, blue: 0.76, alpha: 1))] {
                ctx.addPath(coast); ctx.setStrokeColor(color.cgColor); ctx.setLineWidth(width); ctx.strokePath()
            }
            let capitals = [TileCoordinate.home] + BotFaction.starting.map(\.capital)
            for y in 0..<side {
                for x in 0..<side where heights[y * 201 + x] > 0.62 {
                    let terrain = world.terrain(at: .init(x: x, y: y))
                    let value = WorldTerrainArtwork.variation(x: x, y: y, seed: world.seed)
                    let px = (CGFloat(x) + 0.25 + value * 0.5) * scale
                    let py = (CGFloat(y) + 0.35 + value * 0.3) * scale
                    let nearVillage = capitals.contains { abs($0.x - x) <= 1 && abs($0.y - y) <= 1 }
                    if !nearVillage, sprites.count == 6, terrain == .forest || terrain == .amber {
                        if terrain == .forest && value < 0.35 { continue }
                        let index = terrain == .forest ? min(2, Int(value * 3)) : 3 + min(2, Int(value * 3))
                        let width = scale * (1.65 + value * 0.55)
                        let sprite = sprites[index]
                        let height = width * CGFloat(sprite.height) / CGFloat(sprite.width)
                        WorldTerrainArtwork.draw(sprite, in: CGRect(x: px - width / 2, y: py - height * 0.65,
                                                                   width: width, height: height), context: ctx)
                    } else if !nearVillage, terrain == .forest {
                        ctx.setFillColor(UIColor.black.withAlphaComponent(0.17).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 3, y: py, width: 8, height: 5))
                        ctx.setFillColor(UIColor(red: 0.14, green: 0.32 + Double((x + y) % 3) * 0.04, blue: 0.21, alpha: 1).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 4, y: py - 5, width: 7, height: 8))
                        ctx.setFillColor(UIColor(red: 0.38, green: 0.52, blue: 0.29, alpha: 0.8).cgColor)
                        ctx.fillEllipse(in: CGRect(x: px - 3, y: py - 5, width: 4, height: 3))
                    } else if !nearVillage, terrain == .amber {
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
            // Foam remains on the sea-facing edge, outside the land clipping mask.
            ctx.addPath(coast)
            ctx.setStrokeColor(UIColor(red: 0.91, green: 1, blue: 0.94, alpha: 0.55).cgColor)
            ctx.setLineWidth(1)
            ctx.setLineDash(phase: 0, lengths: [7, 3, 2, 9])
            ctx.strokePath()
        }
        #if DEBUG
        Logger(subsystem: "com.giovanni.mareesambre", category: "WorldMap")
            .notice("Terrain prepared in \(String(describing: started.duration(to: .now)), privacy: .public)")
        #endif
        return image
    }
}
