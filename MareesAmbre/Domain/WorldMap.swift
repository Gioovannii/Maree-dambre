struct WorldMap: Sendable {
    static let side = 200
    let seed: Int
    let tiles: [Terrain]

    init(seed: Int) {
        self.seed = seed
        var tiles: [Terrain] = []
        tiles.reserveCapacity(Self.side * Self.side)
        let anchors = [TileCoordinate.home] + BotFaction.starting.map(\.capital)
        for y in 0..<Self.side {
            for x in 0..<Self.side {
                let nearCapital = anchors.contains { abs($0.x - x) + abs($0.y - y) <= 4 }
                let coarse = Self.noise(x: x / 7, y: y / 7, seed: seed)
                let fine = Self.noise(x: x, y: y, seed: seed)
                let isLand = nearCapital || coarse % 100 > 37
                tiles.append(!isLand ? .sea : fine % 17 == 0 ? .amber : fine % 5 < 2 ? .forest : .meadow)
            }
        }
        self.tiles = tiles
    }

    func terrain(at tile: TileCoordinate) -> Terrain {
        guard tile.isValid else { return .sea }
        return tiles[tile.y * Self.side + tile.x]
    }

    private static func noise(x: Int, y: Int, seed: Int) -> UInt64 {
        var value = UInt64(truncatingIfNeeded: seed) ^ (UInt64(x) &* 374_761_393) ^ (UInt64(y) &* 668_265_263)
        value = (value ^ (value >> 13)) &* 1_274_126_177
        return value ^ (value >> 16)
    }
}
