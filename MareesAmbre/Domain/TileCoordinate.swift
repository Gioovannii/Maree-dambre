struct TileCoordinate: Codable, Hashable, Sendable {
    let x: Int
    let y: Int
    static let home = TileCoordinate(x: 100, y: 100)
    func distance(to other: Self) -> Int { abs(x - other.x) + abs(y - other.y) }
    var isValid: Bool { (0..<200).contains(x) && (0..<200).contains(y) }
}
