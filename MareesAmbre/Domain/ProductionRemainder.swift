struct ProductionRemainder: Codable, Equatable {
    var wood: Double
    var amber: Double
    var provisions: Double

    static let zero = ProductionRemainder(wood: 0, amber: 0, provisions: 0)
}
