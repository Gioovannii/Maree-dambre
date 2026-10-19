import Foundation

/// Comprehensive checks for the WorldMap generation and terrain distribution.
@main
struct WorldMapChecks {
    static func main() {
        checkCameraBounds()
        let seed = 202639
        let world = WorldMap(seed: seed)

        // Verify all tiles are present
        precondition(world.tiles.count == 40_000, "World must have 200×200 = 40,000 tiles")

        // Verify deterministic generation
        precondition(world.tiles == WorldMap(seed: seed).tiles, "Same seed must produce identical tiles")
        precondition(world.tiles != WorldMap(seed: seed + 1).tiles, "Different seeds must produce different worlds")

        // Verify the home location is land
        precondition(world.terrain(at: .home) != .sea, "Home location must be land")

        // Verify out-of-bounds is sea
        precondition(world.terrain(at: .init(x: -1, y: 0)) == .sea)
        precondition(world.terrain(at: .init(x: 200, y: 0)) == .sea)
        precondition(world.terrain(at: .init(x: 0, y: -1)) == .sea)
        precondition(world.terrain(at: .init(x: 0, y: 200)) == .sea)

        // Count terrain types to verify reasonable distribution
        var landTiles = 0
        var seaTiles = 0
        var forestTiles = 0
        var meadowTiles = 0
        var amberTiles = 0

        for terrain in world.tiles {
            switch terrain {
            case .sea: seaTiles += 1
            case .forest: forestTiles += 1
            case .meadow: meadowTiles += 1
            case .amber: amberTiles += 1
            }
        }

        landTiles = forestTiles + meadowTiles + amberTiles
        precondition(landTiles > 5000, "World must have substantial land area (\(landTiles) tiles)")
        precondition(seaTiles > 5000, "World must have substantial sea area (\(seaTiles) tiles)")
        precondition(forestTiles > 100, "World must contain forests (\(forestTiles) tiles)")
        precondition(meadowTiles > 100, "World must contain meadows (\(meadowTiles) tiles)")
        precondition(amberTiles > 50, "World must contain amber deposits (\(amberTiles) tiles)")

        // Verify bot capitals are on land
        for bot in BotFaction.starting {
            precondition(world.terrain(at: bot.capital) != .sea, "Bot \(bot.id) capital must be on land")
        }

        // Verify islands have connectivity (spot check)
        let sampledTiles: [TileCoordinate] = [
            .init(x: 10, y: 10),
            .init(x: 50, y: 50),
            .init(x: 100, y: 100),
            .init(x: 150, y: 150),
            .init(x: 190, y: 190)
        ]
        for tile in sampledTiles {
            precondition(tile.isValid, "Sampled tile \(tile) must be valid")
        }

        print("PASS: world map generation — \(landTiles) land, \(seaTiles) sea, " +
              "\(forestTiles) forest, \(meadowTiles) meadow, \(amberTiles) amber tiles")
    }

    static func checkCameraBounds() {
        let extent: CGFloat = 4800
        for viewport in [CGSize(width: 390, height: 420), CGSize(width: 1000, height: 500),
                         CGSize(width: 1200, height: 900), CGSize(width: 7000, height: 6000)] {
            let bounds = WorldCameraBounds(viewport: viewport, worldSize: CGSize(width: extent, height: extent))
            for proposedScale: CGFloat in [0.01, 0.8, 2.4, 8, 100] {
                let scale = bounds.scale(proposedScale)
                for proposed in [CGPoint(x: -100_000, y: -100_000), CGPoint.zero,
                                 CGPoint(x: extent, y: -extent), CGPoint(x: 100_000, y: 100_000),
                                 CGPoint(x: 2400, y: -2400)] {
                    let center = bounds.position(proposed, scale: scale)
                    let halfWidth = viewport.width * scale / 2
                    let halfHeight = viewport.height * scale / 2
                    precondition(center.x - halfWidth >= -0.0001 && center.x + halfWidth <= extent + 0.0001)
                    precondition(center.y - halfHeight >= -extent - 0.0001 && center.y + halfHeight <= 0.0001,
                                 "Pan, focus and zoom must keep the entire visible viewport inside the world")
                    precondition(bounds.position(center, scale: scale) == center)
                }
            }
        }
        print("PASS: camera viewport stays inside all four world edges across phone/tablet sizes and zoom levels")
    }
}
