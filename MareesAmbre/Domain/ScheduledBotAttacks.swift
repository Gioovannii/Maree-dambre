import Foundation

extension VillageState {
    static let botAttackInterval: TimeInterval = 24 * 3600

    mutating func scheduleBotAttacks(now: Date = .now) {
        guard people != nil else { return }
        let first = max(now, beginnerProtection?.endsAt ?? now).addingTimeInterval(Self.botAttackInterval)
        if !isRefuge && nextBotAttackAt == nil { nextBotAttackAt = first }
        for index in (otherVillages ?? []).indices {
            if otherVillages?[index].isRefuge == false && otherVillages?[index].nextBotAttackAt == nil {
                otherVillages?[index].nextBotAttackAt = first
            }
        }
    }

    var scheduledBotAttackDate: Date? {
        guard !isRefuge, let due = nextBotAttackAt else { return nil }
        return max(due, beginnerProtection?.endsAt.addingTimeInterval(Self.botAttackInterval) ?? due)
    }

    mutating func resolveScheduledAttacks(now: Date) {
        let protection = beginnerProtection
        resolveLocalAttack(now: now, protection: protection)
        for index in (otherVillages ?? []).indices {
            otherVillages?[index].resolveLocalAttack(now: now, protection: protection)
        }
    }

    private mutating func resolveLocalAttack(now: Date, protection: BeginnerProtection?) {
        guard !isRefuge, var due = nextBotAttackAt else { return }
        if let protection, due < protection.endsAt.addingTimeInterval(Self.botAttackInterval) {
            due = protection.endsAt.addingTimeInterval(Self.botAttackInterval)
            nextBotAttackAt = due
        }
        guard now >= due else { return }
        let originalProtection = beginnerProtection
        beginnerProtection = protection
        if coastalCampaign == nil {
            let attacker = bots.min { location.distance(to: $0.capital) < location.distance(to: $1.capital) }
            coastalCampaign = CoastalCampaign(attackerID: attacker?.id,
                attackerPower: min(252, (4 + max(0, (attacker?.level ?? 1) - 1)) * 6))
        }
        let before = coastalCampaign?.assaultsResolved
        for _ in 0..<3 {
            guard coastalCampaign?.assaultsResolved == before else { break }
            if !advanceCoastalTide(now: now) { break }
        }
        beginnerProtection = originalProtection
        // At most one assault per village after an absence; no catch-up backlog.
        nextBotAttackAt = now.addingTimeInterval(Self.botAttackInterval)
    }
}
