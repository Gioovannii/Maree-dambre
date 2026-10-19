import Foundation

enum HeroPortrait: String, Codable, CaseIterable, Identifiable {
    case captainWoman, captainMan
    var id: String { rawValue }
    var assetName: String { self == .captainWoman ? "HeroCaptainWoman" : "HeroCaptainMan" }
    var defaultName: String { self == .captainWoman ? "Élyne" : "Maël" }
}
