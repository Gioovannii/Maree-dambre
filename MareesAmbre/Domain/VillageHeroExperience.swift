import Foundation

extension VillageState {
    mutating func initializeHeroProgression(now: Date) {
        guard var captain = hero, captain.experienceStartedAt == nil else { return }
        captain.experienceStartedAt = now
        captain.experience = captain.experience ?? 0
        hero = captain
    }

    /// The mail reward marker persists with the report. Reading or reopening it cannot grant XP again.
    mutating func awardHeroExperience() {
        guard var captain = hero, let started = captain.experienceStartedAt else { return }
        let pending = allMail.filter { $0.heroExperienceGain == nil }
            .sorted { $0.createdAt == $1.createdAt ? $0.id < $1.id : $0.createdAt < $1.createdAt }
        for mail in pending {
            var gain = 0
            if mail.imported != true && mail.createdAt >= started {
                let day = Int(floor(mail.createdAt.timeIntervalSince1970 / 86_400))
                let reward = heroReward(for: mail)
                if let reward, day >= (captain.rewardDay ?? day) {
                    if captain.rewardDay != day { captain.rewardDay = day; captain.rewardKeys = [] }
                    var keys = captain.rewardKeys ?? []
                    if !keys.contains(reward.key), keys.count < 32 {
                        keys.insert(reward.key)
                        captain.rewardKeys = keys
                        gain = min(reward.points, HeroProgression.maximumExperience - captain.totalExperience)
                        captain.experience = captain.totalExperience + gain
                    }
                }
            }
            markHeroReward(mail.id, gain: gain)
        }
        hero = captain
    }

    private func heroReward(for mail: GameMail) -> (key: String, points: Int)? {
        switch mail.content {
        case .raid(let report):
            guard report.includesHero != false else { return nil }
            // Shared across all villages: one rewarded result per neighbor per UTC day.
            return ("raid.\(report.targetName)", report.won ? HeroProgression.battleVictoryExperience : HeroProgression.battleDefeatExperience)
        case .defense(let report):
            return ("defense.\(mail.village.x).\(mail.village.y)", report.won ? HeroProgression.battleVictoryExperience : HeroProgression.battleDefeatExperience)
        case .colony(let voyage):
            return ("colony.\(voyage.destination.x).\(voyage.destination.y)", HeroProgression.colonyExperience)
        default: return nil
        }
    }

    private mutating func markHeroReward(_ id: String, gain: Int) {
        if let index = mailbox?.firstIndex(where: { $0.id == id }) {
            mailbox?[index].heroExperienceGain = gain
        }
        for index in (otherVillages ?? []).indices {
            if let messageIndex = otherVillages?[index].mailbox?.firstIndex(where: { $0.id == id }) {
                otherVillages?[index].mailbox?[messageIndex].heroExperienceGain = gain
            }
        }
    }
}
