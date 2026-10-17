import Foundation

/// This first campaign advances only through explicit player decisions.
/// Production and expedition clocks remain independent of strategic tides.
struct CoastalCampaign: Codable, Equatable {
    var tide = 0
    var assaultsResolved = 0
    var report: DefenseReport?
    var attackerID: Int? = nil
    var attackerPower: Int? = nil

    var nextAssaultTide: Int { 2 + assaultsResolved * 3 }
    var tidesUntilAssault: Int { nextAssaultTide - tide }
    var enemyCount: Int { enemyPower / 6 }
    var enemyPower: Int { attackerPower ?? (4 + min(19, assaultsResolved) * 2) * 6 }
    var isHighTide: Bool { tide.isMultiple(of: 2) }
    var isValid: Bool {
        guard (0...333_333).contains(assaultsResolved), (0...1_000_000).contains(tide),
              tide < nextAssaultTide, (1...3).contains(tidesUntilAssault),
              attackerID.map({ (0...BotFaction.maximumStartingID).contains($0) }) ?? true,
              attackerPower.map({ (24...252).contains($0) && $0.isMultiple(of: 6) }) ?? true else { return false }
        if let report {
            return report.isValid && assaultsResolved > 0
                && report.tide == 2 + (assaultsResolved - 1) * 3
                && report.tide <= tide
                && (attackerPower != nil || report.enemyPower == (4 + min(19, assaultsResolved - 1) * 2) * 6)
        }
        return assaultsResolved == 0
    }
}

extension ArmyUnit {
    var defense: Int {
        switch self {
        case .tideguard: 10
        case .pillager: 3
        case .amberSentry: 14
        case .tideMage: 4
        case .reedrunner: 7
        case .marshArcher: 12
        }
    }
}

extension VillageState {
    var canStartCoastalCampaign: Bool {
        coastalCampaign == nil && people != nil && hasBuilding(.warCourt)
            && availableArmy.values.contains(where: { $0 > 0 })
    }

    func defensePower(for units: [ArmyUnit: Int]) -> Int {
        units.reduce(0) { $0 + defenseStrength(of: $1.key) * $1.value } + automaticDefense
    }

    var garrisonDefense: Int { defensePower(for: availableArmy) }

    private func assaultPower(attackerLevel: Int, assaultsResolved: Int) -> Int {
        min(252, (4 + min(19, assaultsResolved) * 2 + max(0, attackerLevel - 1)) * 6)
    }

    @discardableResult
    mutating func startCoastalCampaign() -> Bool {
        guard canStartCoastalCampaign else { return false }
        let attacker = bots.min { $0.distanceFromHome < $1.distanceFromHome }
        coastalCampaign = CoastalCampaign(attackerID: attacker?.id,
                                          attackerPower: attacker.map { assaultPower(attackerLevel: $0.level, assaultsResolved: 0) })
        return true
    }

    var defensePreview: DefenseReport? {
        guard let campaign = coastalCampaign, campaign.isValid else { return nil }
        let won = garrisonDefense >= campaign.enemyPower
        let rate = won ? victoryLossRate : defeatLossRate
        var losses: [ArmyUnit: Int] = [:]
        for (unit, count) in availableArmy where count > 0 {
            let lost = won ? Int(floor(Double(count) * rate + 1e-9))
                : Int(ceil(Double(count) * rate - 1e-9))
            if lost > 0 { losses[unit] = min(count, lost) }
        }
        // Preserve a small reserve and every production site after a defeat.
        func stolen(_ stock: Int) -> Int {
            won ? 0 : min(90, campaign.enemyPower / 3, max(0, stock - 20))
        }
        let attackerName = campaign.attackerID.flatMap { id in bots.first(where: { $0.id == id })?.pseudonym(seed: seed) }
        return DefenseReport(tide: campaign.nextAssaultTide, enemyPower: campaign.enemyPower,
                             garrisonPower: garrisonDefense, fortificationPower: automaticDefense,
                             won: won, losses: losses,
                             stolen: Resources(wood: stolen(resources.wood), amber: stolen(resources.amber),
                                               provisions: stolen(resources.provisions)),
                             attackerName: attackerName)
    }

    @discardableResult
    mutating func advanceCoastalTide() -> Bool {
        guard var campaign = coastalCampaign, campaign.isValid, campaign.tide < 1_000_000 else { return false }
        if campaign.tidesUntilAssault == 1 {
            guard let report = defensePreview else { return false }
            var troops = army ?? ArmyState()
            for (unit, count) in report.losses {
                let remaining = troops.units[unit, default: 0] - count
                if remaining == 0 { troops.units.removeValue(forKey: unit) }
                else { troops.units[unit] = remaining }
            }
            army = troops
            resources.wood -= report.stolen.wood
            resources.amber -= report.stolen.amber
            resources.provisions -= report.stolen.provisions
            campaign.report = report
            campaign.assaultsResolved += 1
            let attackers = bots.sorted { $0.distanceFromHome < $1.distanceFromHome }
            if !attackers.isEmpty {
                let next = attackers[campaign.assaultsResolved % attackers.count]
                campaign.attackerID = next.id
                campaign.attackerPower = assaultPower(attackerLevel: next.level, assaultsResolved: campaign.assaultsResolved)
            }
        }
        campaign.tide += 1
        coastalCampaign = campaign
        // The port fights first: escorts returning on this tide cannot also defend it.
        settleConvoy(at: campaign.tide)
        return true
    }
}
