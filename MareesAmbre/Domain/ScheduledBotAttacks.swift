import Foundation

extension VillageState {
    static let botAttackInterval: TimeInterval = 24 * 3600

    mutating func scheduleBotAttacks(now: Date = .now, calendar: Calendar = .current) {
        guard people != nil else { return }
        let first = RaidRestPolicy.attackDate(for: max(now, beginnerProtection?.endsAt ?? now).addingTimeInterval(Self.botAttackInterval), calendar: calendar)
        if !isRefuge && nextBotAttackAt == nil { nextBotAttackAt = first }
        for index in (otherVillages ?? []).indices {
            if otherVillages?[index].isRefuge == false && otherVillages?[index].nextBotAttackAt == nil {
                otherVillages?[index].nextBotAttackAt = first
            }
        }
    }

    var scheduledBotAttackDate: Date? { botAttackDate(protection: beginnerProtection) }

    var nextDomainBotAttackDate: Date? {
        ([self] + (otherVillages ?? [])).compactMap { $0.botAttackDate(protection: beginnerProtection) }.min()
    }

    private func botAttackDate(protection: BeginnerProtection?, calendar: Calendar = .current) -> Date? {
        guard !isRefuge, let due = nextBotAttackAt else { return nil }
        return RaidRestPolicy.attackDate(for: max(due, protection?.endsAt.addingTimeInterval(Self.botAttackInterval) ?? due), calendar: calendar)
    }

    mutating func resolveScheduledAttacks(now: Date, calendar: Calendar = .current) {
        let protection = beginnerProtection
        resolveLocalAttack(now: now, protection: protection, calendar: calendar)
        for index in (otherVillages ?? []).indices {
            otherVillages?[index].resolveLocalAttack(now: now, protection: protection, calendar: calendar)
        }
    }

    private mutating func resolveLocalAttack(now: Date, protection: BeginnerProtection?, calendar: Calendar) {
        guard let due = botAttackDate(protection: protection, calendar: calendar) else { return }
        nextBotAttackAt = due
        guard now >= due else { return }
        guard RaidRestPolicy.allowsAutomaticAttack(at: now, calendar: calendar) else {
            nextBotAttackAt = RaidRestPolicy.attackDate(for: now, calendar: calendar)
            return
        }
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
        nextBotAttackAt = RaidRestPolicy.attackDate(for: now.addingTimeInterval(Self.botAttackInterval), calendar: calendar)
    }
}
