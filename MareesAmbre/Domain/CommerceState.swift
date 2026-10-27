import Foundation

struct CommerceState: Codable, Equatable {
    var nextDepartureTide: [TradeRoute: Int] = [:]
    var nextDepartureAt: [TradeRoute: Date]? = nil
    var report: ConvoyReport?

    var isValid: Bool {
        nextDepartureTide.values.allSatisfy { (0...1_000_006).contains($0) }
            && (nextDepartureAt?.values.allSatisfy { $0 >= .distantPast && $0 <= .distantFuture } ?? true)
            && (report?.isValid ?? true)
    }
}

extension VillageState {
    var hasValidCommerce: Bool {
        guard commerce?.isValid ?? true else { return false }
        if let convoy = army?.convoy {
            guard convoy.isValid, commerce != nil, (commerce?.report?.pendingAmber ?? 0) == 0 else { return false }
            if let departure = convoy.departedAt {
                guard commerce?.nextDepartureAt?[convoy.route] == departure.addingTimeInterval(TradeRoute.restockDuration) else { return false }
            } else {
                guard let campaign = coastalCampaign,
                      convoy.departedAtTide <= campaign.tide, convoy.returnsAtTide > campaign.tide,
                      commerce?.nextDepartureTide[convoy.route] == convoy.departedAtTide + TradeRoute.restockTides else { return false }
            }
        }
        if let report = commerce?.report, let departure = report.order.departedAt {
            guard let next = commerce?.nextDepartureAt?[report.order.route],
                  next >= departure.addingTimeInterval(TradeRoute.restockDuration) else { return false }
        }
        if let report = commerce?.report, report.order.departedAt == nil {
            guard let campaign = coastalCampaign, report.order.returnsAtTide <= campaign.tide,
                  let next = commerce?.nextDepartureTide[report.order.route],
                  next >= report.order.departedAtTide + TradeRoute.restockTides else { return false }
        }
        return true
    }

    func convoyCapacity(for units: [ArmyUnit: Int]) -> Int {
        units.reduce(0) { $0 + $1.key.carrying * $1.value } * (100 + transportBonusPercent) / 100
    }

    func canSendConvoy(on route: TradeRoute, units: [ArmyUnit: Int], now: Date? = nil) -> Bool {
        if let now {
            guard now >= .distantPast, now.addingTimeInterval(TradeRoute.restockDuration) <= .distantFuture,
                  now >= (commerce?.nextDepartureAt?[route] ?? .distantPast) else { return false }
        } else {
            guard let campaign = coastalCampaign, campaign.isValid,
                  campaign.tide <= 1_000_000 - route.duration,
                  campaign.tide >= (commerce?.nextDepartureTide[route] ?? 0) else { return false }
        }
        guard hasBuilding(.market),
              army?.convoy == nil, (commerce?.report?.pendingAmber ?? 0) == 0,
              resources.wood >= TradeRoute.cargoWood, resources.provisions >= TradeRoute.travelProvisions,
              units.values.contains(where: { $0 > 0 }),
              units.allSatisfy({ $0.value >= 0 && $0.value <= availableArmy[$0.key, default: 0] }) else { return false }
        return convoyCapacity(for: units) >= TradeRoute.cargoWood
    }

    func convoyPreview(on route: TradeRoute, units: [ArmyUnit: Int], now: Date? = nil) -> ConvoyReport? {
        guard canSendConvoy(on: route, units: units, now: now) else { return nil }
        var order = ConvoyOrder(route: route, departedAtTide: coastalCampaign?.tide ?? 0, units: units.filter { $0.value > 0 },
                                attackUpgrade: weaponLevel, transportBonusPercent: transportBonusPercent,
                                victoryLossRate: victoryLossRate(for: units), defeatLossRate: defeatLossRate,
                                weaponLevels: Dictionary(uniqueKeysWithValues: units.filter { $0.value > 0 }.keys.map { ($0, weaponLevel(for: $0)) }))
        order.departedAt = now
        return ConvoyReport(order: order)
    }

    @discardableResult
    mutating func sendConvoy(on route: TradeRoute, units: [ArmyUnit: Int], now: Date? = nil) -> Bool {
        guard let preview = convoyPreview(on: route, units: units, now: now) else { return false }
        var troops = army ?? ArmyState()
        // Preserve access to legacy units even while the last one is away.
        troops.unlockedUnits = unlockedUnits
        troops.convoy = preview.order
        for (unit, count) in preview.order.units {
            let remaining = troops.units[unit, default: 0] - count
            if remaining == 0 { troops.units.removeValue(forKey: unit) }
            else { troops.units[unit] = remaining }
        }
        var trade = commerce ?? CommerceState()
        if let now {
            var dates = trade.nextDepartureAt ?? [:]
            dates[route] = now.addingTimeInterval(TradeRoute.restockDuration)
            trade.nextDepartureAt = dates
        } else {
            trade.nextDepartureTide[route] = preview.order.departedAtTide + TradeRoute.restockTides
        }
        resources.wood -= TradeRoute.cargoWood
        resources.provisions -= TradeRoute.travelProvisions
        army = troops
        commerce = trade
        return true
    }

    mutating func settleConvoy(at tide: Int) {
        guard var troops = army, let convoy = troops.convoy, convoy.departedAt == nil, tide >= convoy.returnsAtTide else { return }
        let report = ConvoyReport(order: convoy)
        receiveMail(.commerce(report), key: "commerce.\(convoy.departedAtTide)", at: lastProductionAt ?? .now)
        for (unit, count) in convoy.units {
            troops.units[unit, default: 0] += count - report.losses(of: unit)
        }
        troops.units = troops.units.filter { $0.value > 0 }
        troops.convoy = nil
        army = troops
        var trade = commerce ?? CommerceState()
        trade.report = report
        commerce = trade
    }

    var canClaimConvoyReward: Bool {
        guard let reward = commerce?.report?.pendingAmber, reward > 0 else { return false }
        return resources.amber <= storageCapacity - reward
    }

    @discardableResult
    mutating func claimConvoyReward() -> Bool {
        guard canClaimConvoyReward, let reward = commerce?.report?.pendingAmber else { return false }
        resources.amber += reward
        commerce?.report?.rewardClaimed = true
        return true
    }
}
