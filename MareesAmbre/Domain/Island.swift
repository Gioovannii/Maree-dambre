import Foundation

struct Island: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let subtitle: String
    let x: Double
    let y: Double
    let isHome: Bool
    var portLevel: Int
}
