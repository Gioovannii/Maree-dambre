struct TileCoordinate: Codable, Hashable, Sendable {
    let x: Int
    let y: Int
    static let home = TileCoordinate(x: 100, y: 100)
    var isValid: Bool { (0..<200).contains(x) && (0..<200).contains(y) }
}
