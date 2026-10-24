import Foundation

/// Plays legal actions against the real clock and economy; never grants resources or levels.
@main
struct CampaignJourneyChecks {
    static func main() throws {
        for people in People.allCases {
            var journey = Journey(people: people)
            try journey.run()
        }
    }
}

private enum JourneyFailure: Error, CustomStringConvertible {
    case blocked(String)
    var description: String { if case .blocked(let reason) = self { reason } else { "" } }
}

private struct Journey {
    let world = WorldMap(seed: 42)
    let startedAt = Date(timeIntervalSince1970: 1_800_000_000)
    var now = Date(timeIntervalSince1970: 1_800_000_000)
    var state = VillageState(seed: 42)
    var longestWait: TimeInterval = 0
    var longestWaitReason = ""

    init(people: People) {
        state.people = people
        state.lastProductionAt = startedAt
        state.lastBotExpansionAt = startedAt
        state.beginProtection(now: startedAt)
        state.scheduleBotAttacks(now: startedAt)
    }

    mutating func advance(to date: Date) {
        now = date
        state.updateDomain(now: now, on: world)
    }

    mutating func waitFor(_ label: String, condition: (VillageState) -> Bool) throws {
        let began = now
        while !condition(state) {
            guard now.timeIntervalSince(began) < 30 * 86_400 else {
                throw JourneyFailure.blocked("\(state.people!.rawValue): \(label) blocked for 30 days; stock \(state.resources), storage \(state.storageCapacity), production \(state.production)")
            }
            advance(to: now.addingTimeInterval(60))
        }
        let waited = now.timeIntervalSince(began)
        if waited > longestWait { longestWait = waited; longestWaitReason = label }
    }

    mutating func afford(_ cost: Resources, label: String) throws {
        guard max(cost.wood, cost.amber, cost.provisions) <= state.storageCapacity else {
            throw JourneyFailure.blocked("\(label): cost \(cost) exceeds storage \(state.storageCapacity)")
        }
        try waitFor(label) { $0.canAffordExpansion(cost) }
    }

    mutating func building(_ kind: BuildingKind, level: Int = 1) throws {
        if !state.hasBuilding(kind) {
            guard let plot = VillageMapMode.townCenter.defaultVisibleSlots.first(where: {
                state.buildings[$0] == nil && VillageState.canPlace(kind, at: $0)
            }) else { throw JourneyFailure.blocked("No plot available for \(kind)") }
            try afford(kind.cost, label: "build \(kind)")
            guard state.build(kind, at: plot, now: now) else { throw JourneyFailure.blocked("Cannot build \(kind)") }
            advance(to: state.construction!.endsAt)
        }
        while state.buildingLevel(kind) < level {
            let plot = state.buildings.first { $0.value == kind }!.key
            try afford(kind.cost(for: state.buildingLevel(kind) + 1), label: "upgrade \(kind)")
            guard state.upgradeBuilding(at: plot, now: now) else { throw JourneyFailure.blocked("Cannot upgrade \(kind)") }
            advance(to: state.construction!.endsAt)
        }
    }

    mutating func field(_ plot: Int, level: Int) throws {
        while state.resourceLevel(at: plot) < level {
            try afford(ResourceSiteKind.at(plot)!.cost(for: state.resourceLevel(at: plot) + 1), label: "field \(plot)")
            guard state.developResource(at: plot, now: now) else { throw JourneyFailure.blocked("Cannot develop field \(plot)") }
            advance(to: state.resourceUpgrade!.endsAt)
        }
    }

    mutating func recruit(_ unit: ArmyUnit, count: Int) throws {
        let cost = Resources(wood: unit.cost.wood * count, amber: unit.cost.amber * count, provisions: unit.cost.provisions * count)
        try afford(cost, label: "recruit \(unit)")
        guard state.train(unit, count: count, now: now) else { throw JourneyFailure.blocked("Cannot train \(count) \(unit)") }
        advance(to: state.army!.training!.endsAt)
    }

    mutating func checkpoint(_ label: String) throws {
        let suite = "CampaignJourneyChecks.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = VillageStorage(defaults: defaults)
        try storage.save(state)
        guard let restored = try storage.load(seed: state.seed, world: world, now: now), restored == state else {
            throw JourneyFailure.blocked("Save changed at \(label)")
        }
        state = restored
        print("JOURNEY \(state.people!.rawValue): \(label) at \(String(format: "%.2f", now.timeIntervalSince(startedAt) / 3600)) h")
    }

    mutating func run() throws {
        let basic = state.peopleUnits[0]
        while VillageGuideStep.next(in: state) == .fields {
            guard let plot = state.recommendedGuideResourcePlot else { throw JourneyFailure.blocked("No tutorial resource target") }
            try field(plot, level: 1)
        }
        try building(.academy)
        try building(.warCourt)
        try afford(basic.researchCost, label: "first research")
        guard state.research(basic, now: now) else { throw JourneyFailure.blocked("Cannot research basic unit") }
        advance(to: state.army!.research!.endsAt)
        try recruit(basic, count: 2)
        guard state.raid(targetID: 0, now: now) else { throw JourneyFailure.blocked("Cannot launch first raid") }
        advance(to: state.army!.raid!.returnsAt)
        guard now.timeIntervalSince(startedAt) < 3600 else { throw JourneyFailure.blocked("First guided raid takes over an hour") }
        try checkpoint("first raid returned")

        try building(.warehouse, level: 3)
        // Grow the full economy before investing in expansion prerequisites.
        for level in 1...4 {
            for plot in VillageMapMode.resourceFields.slots { try field(plot, level: level) }
        }
        try building(.hall, level: 5)
        try building(.academy, level: 3)
        try building(.expeditionQuay, level: 2)
        try recruit(basic, count: 10)
        try afford(VillageState.navigationCost, label: "navigation")
        guard state.researchNavigation(now: now) else { throw JourneyFailure.blocked("Navigation prerequisites unreachable") }
        advance(to: state.expansion!.researchEndsAt!)
        try afford(VillageState.settlersCost, label: "settlers")
        guard state.prepareSettlers(now: now) else { throw JourneyFailure.blocked("Cannot prepare settlers") }
        advance(to: state.expansion!.settlersEndAt!)
        try afford(state.foundationCost, label: "foundation")
        guard let site = state.suggestedSettlementSites(on: world).last,
              state.found(at: site, role: .production, escort: basic, on: world, now: now) else {
            throw JourneyFailure.blocked("Cannot found second village")
        }
        try checkpoint("colonists sailing")
        advance(to: state.expansion!.voyage!.arrivesAt)
        guard state.settlementCount == 2 else { throw JourneyFailure.blocked("Colony did not arrive") }
        try checkpoint("second village")
        guard state.switchSettlement(to: site) else { throw JourneyFailure.blocked("Cannot visit colony") }
        try field(0, level: 2)
        guard state.switchSettlement(to: .home) else { throw JourneyFailure.blocked("Cannot return to capital") }

        try building(.warehouse, level: 7)
        try building(.warCourt, level: 2)
        while state.mobilizedTroopCount < 120 {
            try recruit(basic, count: min(20, 120 - state.mobilizedTroopCount))
        }
        try checkpoint("army above 100")
        // Invest in production before committing to the most expensive weapon tiers.
        for (plot, kind) in [(0, BuildingKind.lumbermill), (2, .farm), (4, .amberWorks)] {
            try field(plot, level: 10)
            try building(kind)
        }
        try building(.watchtower)
        try building(.market)
        try building(.infirmary)
        try building(.forge, level: 10)
        while state.weaponLevel(for: basic) < 10 {
            try afford(state.weaponUpgradeCost(for: basic), label: "weapons")
            guard state.upgradeWeapons(for: basic, now: now) else { throw JourneyFailure.blocked("Cannot upgrade weapons") }
            advance(to: state.weaponUpgrade!.endsAt)
        }
        try checkpoint("advanced buildings and weapons")
        guard state.allMail.contains(where: { if case .defense = $0.content { true } else { false } }) else {
            throw JourneyFailure.blocked("Journey did not exercise automatic attacks")
        }
        print("JOURNEY \(state.people!.rawValue): longest uninterrupted resource wait \(String(format: "%.2f", longestWait / 3600)) h (\(longestWaitReason))")
    }
}
