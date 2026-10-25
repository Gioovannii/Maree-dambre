import Foundation

extension VillageState {
    static let minimumBotAttackInterval: TimeInterval = 8 * 24 * 3600
    static let maximumBotAttackInterval: TimeInterval = 15 * 24 * 3600

    mutating func scheduleBotAttacks(now: Date = .now, calendar: Calendar = .current) {
        guard people != nil else { return }
        let settlements = [self] + (otherVillages ?? [])
        guard settlements.contains(where: { !$0.isRefuge }) else { return }

        let existing = settlements.compactMap(\.nextBotAttackAt).min()
        let anchor = max(now, beginnerProtection?.endsAt ?? now)
        let first = existing ?? RaidRestPolicy.attackDate(
            for: anchor.addingTimeInterval(botAttackDelay(anchor: anchor, salt: 0)), calendar: calendar)
        setDomainBotAttackDate(first)
        botRaidTarget = selectedBotRaidTarget(at: first)?.location
    }

    var scheduledBotAttackDate: Date? { botAttackDate(protection: beginnerProtection) }

    var nextDomainBotAttackDate: Date? {
        ([self] + (otherVillages ?? [])).compactMap {
            $0.botAttackDate(protection: beginnerProtection)
        }.min()
    }

    var nextBotRaidTargetName: String? {
        guard let due = nextDomainBotAttackDate else { return nil }
        return selectedBotRaidTarget(at: due)?.settlementName
    }

    private func selectedBotRaidTarget(at due: Date) -> VillageState? {
        let eligible = ([self] + (otherVillages ?? [])).filter { !$0.isRefuge }.sorted {
            let lhs = $0.location
            let rhs = $1.location
            return lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
        }
        if let target = eligible.first(where: { $0.location == botRaidTarget }) { return target }
        guard !eligible.isEmpty else { return nil }
        return eligible[randomIndex(anchor: due, count: eligible.count, salt: 0x4f1bbcdc)]
    }

    private func botAttackDate(protection: BeginnerProtection?, calendar: Calendar = .current) -> Date? {
        guard !isRefuge, let due = nextBotAttackAt else { return nil }
        let protectionDeadline = protection.map { $0.endsAt.addingTimeInterval(botAttackDelay(anchor: $0.endsAt, salt: 0)) }
        return RaidRestPolicy.attackDate(for: max(due, protectionDeadline ?? due), calendar: calendar)
    }

    /// All settlements share one attack deadline. A single target is chosen when it arrives.
    mutating func resolveScheduledAttacks(now: Date, calendar: Calendar = .current) {
        guard people != nil else { return }
        let settlements = [self] + (otherVillages ?? [])
        let pending = settlements.compactMap(\.nextBotAttackAt).min()
        guard let pending else { return }

        let due = RaidRestPolicy.attackDate(
            for: max(pending, beginnerProtection.map {
                $0.endsAt.addingTimeInterval(botAttackDelay(anchor: $0.endsAt, salt: 0))
            } ?? pending), calendar: calendar)
        botRaidTarget = selectedBotRaidTarget(at: due)?.location
        guard now >= due else {
            setDomainBotAttackDate(due)
            return
        }
        guard RaidRestPolicy.allowsAutomaticAttack(at: now, calendar: calendar) else {
            setDomainBotAttackDate(RaidRestPolicy.attackDate(for: now, calendar: calendar))
            return
        }

        guard let targetIndex = settlements.firstIndex(where: { $0.location == botRaidTarget && !$0.isRefuge }) else {
            setDomainBotAttackDate(nil)
            botRaidTarget = nil
            return
        }
        if targetIndex == 0 {
            Self.resolveAutomaticAttack(in: &self, now: now, protection: beginnerProtection, bots: bots,
                                        attackerIndex: randomIndex(anchor: due, count: max(1, bots.count), salt: 0x71a5))
        } else if var villages = otherVillages {
            let index = targetIndex - 1
            if villages.indices.contains(index) {
                Self.resolveAutomaticAttack(in: &villages[index], now: now, protection: beginnerProtection, bots: bots,
                                            attackerIndex: randomIndex(anchor: due, count: max(1, bots.count), salt: 0x71a5))
                otherVillages = villages
            }
        }

        let delay = botAttackDelay(anchor: due, salt: 0xa31d)
        let nextDue = RaidRestPolicy.attackDate(for: now.addingTimeInterval(delay), calendar: calendar)
        setDomainBotAttackDate(nextDue)
        botRaidTarget = nil
        botRaidTarget = selectedBotRaidTarget(at: nextDue)?.location
    }

    private mutating func setDomainBotAttackDate(_ date: Date?) {
        nextBotAttackAt = isRefuge ? nil : date
        guard var villages = otherVillages else { return }
        for index in villages.indices {
            villages[index].nextBotAttackAt = villages[index].isRefuge ? nil : date
        }
        otherVillages = villages
    }

    private func botAttackDelay(anchor: Date, salt: UInt64) -> TimeInterval {
        let secondsPerDay: TimeInterval = 24 * 3600
        let minimumDays = Int(Self.minimumBotAttackInterval / secondsPerDay)
        let maximumDays = Int(Self.maximumBotAttackInterval / secondsPerDay)
        let days = minimumDays + randomIndex(anchor: anchor, count: maximumDays - minimumDays + 1, salt: salt)
        return TimeInterval(days) * 24 * 3600
    }

    private func randomIndex(anchor: Date, count: Int, salt: UInt64) -> Int {
        guard count > 1 else { return 0 }
        let day = Int64(anchor.timeIntervalSince1970 / (24 * 3600))
        var value = UInt64(truncatingIfNeeded: seed) ^ UInt64(bitPattern: day) ^ salt
        value ^= value >> 30
        value = value &* 0xbf58476d1ce4e5b9
        value ^= value >> 27
        value = value &* 0x94d049bb133111eb
        value ^= value >> 31
        return Int(value % UInt64(count))
    }

    private static func resolveAutomaticAttack(in village: inout VillageState, now: Date,
                                               protection: BeginnerProtection?, bots: [BotFaction], attackerIndex: Int) {
        let originalProtection = village.beginnerProtection
        village.beginnerProtection = protection
        if village.coastalCampaign == nil {
            let attacker = bots.sorted { $0.id < $1.id }.dropFirst(attackerIndex).first
            village.coastalCampaign = CoastalCampaign(attackerID: attacker?.id,
                attackerPower: min(252, (4 + max(0, (attacker?.level ?? 1) - 1)) * 6))
        }
        let before = village.coastalCampaign?.assaultsResolved
        for _ in 0..<3 {
            guard village.coastalCampaign?.assaultsResolved == before else { break }
            if !village.advanceCoastalTide(now: now) { break }
        }
        village.beginnerProtection = originalProtection
    }
}
