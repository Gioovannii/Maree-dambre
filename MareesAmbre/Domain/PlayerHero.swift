import Foundation

struct PlayerHero: Codable, Equatable {
    var portrait: HeroPortrait
    var name: String
    var experience: Int?
    var experienceStartedAt: Date?
    var rewardDay: Int?
    var rewardKeys: Set<String>?
    var missions: HeroMissions?

    var isValid: Bool {
        Self.normalizedName(name) == name
            && (missions?.isValid ?? true)
            && level >= HeroEquipmentKind.requiredHeroLevel(for: (missions?.equipment ?? HeroEquipment()).highestLevel)
            && (0...HeroProgression.maximumExperience).contains(experience ?? 0)
            && (experienceStartedAt.map { $0 >= .distantPast && $0 <= .distantFuture } ?? true)
            && (rewardDay.map { (-1_000_000...1_000_000).contains($0) } ?? true)
            && (rewardKeys ?? []).count <= 32
            && (rewardKeys ?? []).allSatisfy { !$0.isEmpty && $0.count <= 100 }
    }


    static func normalizedName(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...24).contains(trimmed.count),
              trimmed.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) && !CharacterSet.newlines.contains($0) }) else { return nil }
        return trimmed
    }
}

extension VillageState {
    var heroIsOnRaid: Bool {
        ([self] + (otherVillages ?? [])).contains { $0.army?.raid?.includesHero == true }
    }
    var heroCanJoinRaid: Bool { hero != nil && hero?.missions?.voyage == nil && !heroIsOnRaid }
    var heroRaidAttackBonus: Int { min(20, (hero?.level ?? 0) * 2) }

    @discardableResult
    mutating func customizeHero(portrait: HeroPortrait, name: String, now: Date = .now) -> Bool {
        guard people != nil, let name = PlayerHero.normalizedName(name) else { return false }
        var captain = hero ?? PlayerHero(portrait: portrait, name: name)
        captain.portrait = portrait
        captain.name = name
        hero = captain
        initializeHeroProgression(now: now)
        return true
    }
}
