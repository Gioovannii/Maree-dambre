import Foundation

struct GameMail: Codable, Equatable, Identifiable {
    let id: String
    let createdAt: Date
    let village: TileCoordinate
    let content: GameMailContent
    var isRead = false
    var imported: Bool?
    var heroExperienceGain: Int?

    var isValid: Bool {
        !id.isEmpty && id.count <= 256 && village.isValid
            && (heroExperienceGain.map { (0...75).contains($0) } ?? true)
            && createdAt >= .distantPast && createdAt <= .distantFuture && content.isValid
    }
}
