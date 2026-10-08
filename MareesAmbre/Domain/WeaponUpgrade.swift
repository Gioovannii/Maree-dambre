import Foundation

struct WeaponUpgrade: Codable, Equatable {
    let targetLevel: Int
    let endsAt: Date
}
