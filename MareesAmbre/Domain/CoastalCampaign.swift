import Foundation

/// This first campaign advances only through explicit player decisions.
/// Production and expedition clocks remain independent of strategic tides.
struct CoastalCampaign: Codable, Equatable {
    var tide = 0
    var assaultsResolved = 0
    var report: DefenseReport?

    var nextAssaultTide: Int { 2 + assaultsResolved * 3 }
    var tidesUntilAssault: Int { nextAssaultTide - tide }
    var enemyCount: Int { 4 + min(19, assaultsResolved) * 2 }
    var enemyPower: Int { enemyCount * 6 }
    var isHighTide: Bool { tide.isMultiple(of: 2) }
    var isValid: Bool {
        guard (0...333_333).contains(assaultsResolved), (0...1_000_000).contains(tide),
              tide < nextAssaultTide, (1...3).contains(tidesUntilAssault) else { return false }
        if let report {
            return report.isValid && assaultsResolved > 0
                && report.tide == 2 + (assaultsResolved - 1) * 3
                && report.tide <= tide
                && report.enemyPower == (4 + min(19, assaultsResolved - 1) * 2) * 6
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
        units.reduce(0) { $0 + ($1.key.defense + weaponLevel) * $1.value } + automaticDefense
    }

    var garrisonDefense: Int { defensePower(for: availableArmy) }

    @discardableResult
    mutating func startCoastalCampaign() -> Bool {
        guard canStartCoastalCampaign else { return false }
        coastalCampaign = CoastalCampaign()
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
        return DefenseReport(tide: campaign.nextAssaultTide, enemyPower: campaign.enemyPower,
                             garrisonPower: garrisonDefense, fortificationPower: automaticDefense,
                             won: won, losses: losses,
                             stolen: Resources(wood: stolen(resources.wood), amber: stolen(resources.amber),
                                               provisions: stolen(resources.provisions)))
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
        }
        campaign.tide += 1
        coastalCampaign = campaign
        // The port fights first: escorts returning on this tide cannot also defend it.
        settleConvoy(at: campaign.tide)
        return true
    }
}
