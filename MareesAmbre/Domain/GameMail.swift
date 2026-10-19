import Foundation

struct GameMail: Codable, Equatable, Identifiable {
    let id: String
    let createdAt: Date
    let village: TileCoordinate
    let content: GameMailContent
    var isRead = false
    var imported: Bool?

    var isValid: Bool {
        !id.isEmpty && id.count <= 256 && village.isValid
            && createdAt >= .distantPast && createdAt <= .distantFuture && content.isValid
    }
}
