import Foundation

struct DomainObjective: Equatable {
    enum Kind: Int { case colony, forge, capital, thirdVillage, established }
    let kind: Kind
    let progress: Int
    let total: Int
    let location: TileCoordinate
    var resourcePlot: Int? = nil
    var building: BuildingKind? = nil
}

extension VillageState {
    var nextDomainObjective: DomainObjective? {
        guard settlementCount >= 2 else { return nil }
        let villages = [self] + (otherVillages ?? [])
        guard let capital = villages.first(where: { $0.location == .home }),
              let colony = villages.filter({ $0.location != .home }).sorted(by: {
                  let left = $0
                  let right = $1
                  let lhsReady = ResourceSiteKind.allCases.filter { kind in
                      VillageMapMode.resourceFields.slots.contains { ResourceSiteKind.at($0) == kind && left.resourceLevel(at: $0) >= 3 }
                  }.count
                  let rhsReady = ResourceSiteKind.allCases.filter { kind in
                      VillageMapMode.resourceFields.slots.contains { ResourceSiteKind.at($0) == kind && right.resourceLevel(at: $0) >= 3 }
                  }.count
                  if lhsReady != rhsReady { return lhsReady > rhsReady }
                  let lhs = ($0.resourceLevels ?? [:]).values.reduce(0, +)
                  let rhs = ($1.resourceLevels ?? [:]).values.reduce(0, +)
                  if lhs != rhs { return lhs > rhs }
                  return $0.location.x == $1.location.x ? $0.location.y < $1.location.y : $0.location.x < $1.location.x
              }).first else { return nil }
        let sites = ResourceSiteKind.allCases.compactMap { kind in
            VillageMapMode.resourceFields.slots.filter { ResourceSiteKind.at($0) == kind }
                .max { colony.resourceLevel(at: $0) < colony.resourceLevel(at: $1) }
        }
        let ready = sites.filter { colony.resourceLevel(at: $0) >= 3 }.count
        if let plot = sites.first(where: { colony.resourceLevel(at: $0) < 3 }) {
            return DomainObjective(kind: .colony, progress: ready, total: 3, location: colony.location, resourcePlot: plot)
        }
        if capital.buildingLevel(.forge) < 3 {
            return DomainObjective(kind: .forge, progress: capital.buildingLevel(.forge), total: 3,
                                   location: .home, building: .forge)
        }
        let requirements: [(BuildingKind, Int)] = [(.hall, 8), (.academy, 5), (.expeditionQuay, 3), (.warehouse, 7)]
        let completed = requirements.filter { capital.buildingLevel($0.0) >= $0.1 }.count
        if let missing = requirements.first(where: { capital.buildingLevel($0.0) < $0.1 }) {
            return DomainObjective(kind: .capital, progress: completed, total: requirements.count,
                                   location: .home, building: missing.0)
        }
        if settlementCount < Self.maximumSettlements {
            return DomainObjective(kind: .thirdVillage, progress: settlementCount, total: Self.maximumSettlements, location: .home)
        }
        return DomainObjective(kind: .established, progress: 4, total: 4, location: .home)
    }
}
