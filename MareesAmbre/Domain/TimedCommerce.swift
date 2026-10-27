import Foundation

extension VillageState {
    /// Upgrade the old turn-based clock without losing reserved cargo or escorts.
    mutating func migrateCommerceClock(now: Date) {
        guard let campaign = coastalCampaign, commerce != nil else { return }
        if commerce?.nextDepartureAt == nil {
            let legacyDates = commerce?.nextDepartureTide ?? [:]
            commerce?.nextDepartureAt = Dictionary(uniqueKeysWithValues:
                legacyDates.map { route, tide in
                    (route, now.addingTimeInterval(Double(max(0, tide - campaign.tide)) * 600))
                })
        }
        if let convoy = army?.convoy, convoy.departedAt == nil {
            let elapsed = min(convoy.route.duration, max(0, campaign.tide - convoy.departedAtTide))
            let departure = now.addingTimeInterval(-Double(elapsed) * 600)
            army?.convoy?.departedAt = departure
            commerce?.nextDepartureAt?[convoy.route] = departure.addingTimeInterval(TradeRoute.restockDuration)
        }
    }

    mutating func settleTimedConvoy(now: Date) {
        guard var troops = army, let convoy = troops.convoy, let end = convoy.returnsAt, now >= end else { return }
        let report = ConvoyReport(order: convoy)
        receiveMail(.commerce(report), key: "commerce.time.\(convoy.departedAt!.timeIntervalSince1970)", at: end)
        for (unit, count) in convoy.units {
            troops.units[unit, default: 0] += count - report.losses(of: unit)
        }
        troops.units = troops.units.filter { $0.value > 0 }
        troops.convoy = nil
        army = troops
        commerce?.report = report
    }
}
