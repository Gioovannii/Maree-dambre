import Foundation

struct WorldExpedition: Equatable, Identifiable {
    let id: String
    let origin: TileCoordinate
    let destination: TileCoordinate
    let startedAt: Date
    let endsAt: Date
    let title: String
    let isRaid: Bool
    let includesHero: Bool

    func progress(at date: Date) -> Double {
        min(1, max(0, date.timeIntervalSince(startedAt) / max(1, endsAt.timeIntervalSince(startedAt))))
    }
    func isReturning(at date: Date) -> Bool { progress(at: date) >= 0.5 }
}

extension HeroVoyage {
    /// A stable illustrated destination for missions without a selected map tile.
    /// It affects presentation only, never travel duration or mission rewards.
    var mapDestination: TileCoordinate {
        let offset: (Int, Int)
        switch mission {
        case .discoverWreck: offset = (12, -8)
        case .recoverBoat: offset = (12, -8)
        case .repairBoat: offset = (0, 0)
        case .surveyCoast: offset = (-16, 12)
        case .rescueCrew: offset = (20, 14)
        }
        return TileCoordinate(x: min(199, max(0, origin.x + offset.0)),
                              y: min(199, max(0, origin.y + offset.1)))
    }
}

extension VillageState {
    var worldExpeditions: [WorldExpedition] {
        var result: [WorldExpedition] = []
        for village in [self] + (otherVillages ?? []) {
            guard let raid = village.army?.raid,
                  let target = bots.first(where: { $0.id == raid.targetID }) else { continue }
            result.append(WorldExpedition(id: "raid.\(village.location.x).\(village.location.y)",
                origin: village.location, destination: target.capital,
                startedAt: raid.departedAt ?? raid.returnsAt.addingTimeInterval(-village.raidDuration(to: target)),
                endsAt: raid.returnsAt, title: raid.targetName, isRaid: true, includesHero: raid.includesHero == true))
        }
        if let voyage = hero?.missions?.voyage, voyage.mission != .repairBoat {
            result.append(WorldExpedition(id: "hero", origin: voyage.origin, destination: voyage.mapDestination,
                startedAt: voyage.startedAt, endsAt: voyage.endsAt, title: voyage.mission.title,
                isRaid: false, includesHero: true))
        }
        return result.sorted { $0.id < $1.id }
    }
}
