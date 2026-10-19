import Foundation

enum HeroProgression {
    static let maximumLevel = 20
    static let battleVictoryExperience = 20
    static let battleDefeatExperience = 5
    static let colonyExperience = 75

    static func threshold(for level: Int) -> Int {
        let steps = max(0, min(maximumLevel, level) - 1)
        return steps * 100 + steps * (steps - 1) * 25
    }
    static var maximumExperience: Int { threshold(for: maximumLevel) }
}

extension PlayerHero {
    var totalExperience: Int { experience ?? 0 }
    var level: Int {
        (1...HeroProgression.maximumLevel).last { totalExperience >= HeroProgression.threshold(for: $0) } ?? 1
    }
    var isMaximumLevel: Bool { level == HeroProgression.maximumLevel }
    var experienceInLevel: Int { totalExperience - HeroProgression.threshold(for: level) }
    var experienceForNextLevel: Int {
        isMaximumLevel ? 0 : HeroProgression.threshold(for: level + 1) - HeroProgression.threshold(for: level)
    }
}
