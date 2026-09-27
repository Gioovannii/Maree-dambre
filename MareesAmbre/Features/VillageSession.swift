import Foundation
import Observation

@MainActor @Observable
final class VillageSession {
    private(set) var state: VillageState
    let world: WorldMap
    var plot = VillageMapMode.resourceFields.initialPlot
    var selectedTile = TileCoordinate.home
    private(set) var message = "Choisissez un emplacement libre pour construire."
    private(set) var moveSourcePlot: Int?
    private(set) var elapsedSeconds = 0
    private let storage = VillageStorage()
    private var productionTask: Task<Void, Never>?
    private let isUISnapshot: Bool

    init() {
        isUISnapshot = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
        let seed = isUISnapshot ? 42 : WeeklyChallenge.seed(for: .now)
        world = WorldMap(seed: seed)
        state = VillageState(seed: seed)
        if isUISnapshot {
            state.people = .sauniers
            state.resources = Resources(wood: 180, amber: 40, provisions: 240)
            state.buildings = [
                12: .hall, 10: .lumbermill, 11: .watchtower,
                13: .farm, 15: .amberWorks, 16: .warehouse
            ]
            state.resourceLevels = [0: 1, 1: 0, 2: 1, 3: 1, 4: 0, 5: 1, 6: 1, 7: 0, 8: 0, 9: 0]
            return
        }
        do {
            if let saved = try storage.load(seed: seed, world: world) { state = saved }
        } catch {
            message = "Sauvegarde du village illisible. Un village neuf est affiché ; la prochaine action remplacera cette sauvegarde."
        }
        refreshWorld()
        productionTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { return }
                self?.refreshWorld()
            }
        }
    }

    func choosePeople(_ people: People) {
        guard state.people == nil else { return }
        state.people = people
        persist("\(people.name) veille désormais sur Port d’Ambre.")
    }

    func developSelectedResource() {
        refreshWorld()
        guard state.developResource(at: plot), let kind = ResourceSiteKind.at(plot) else { return }
        persist("\(kind.name) développée. Sa production continue même hors ligne.")
    }

    func build(_ kind: BuildingKind) {
        refreshWorld()
        guard state.build(kind, at: plot) else { return }
        persist("\(kind.name) construite. La production commence maintenant.")
    }

    func beginMovingSelectedBuilding() {
        guard let kind = state.buildings[plot], kind != .hall else { return }
        moveSourcePlot = plot
        message = "Touchez une case libre compatible pour déplacer \(kind.name.lowercased())."
    }

    func cancelMovingBuilding() {
        moveSourcePlot = nil
        message = "Déplacement annulé."
    }

    func selectPlot(_ destination: Int) {
        if let source = moveSourcePlot {
            guard state.moveBuilding(from: source, to: destination),
                  let kind = state.buildings[destination] else {
                message = "Cette case ne peut pas accueillir ce bâtiment."
                return
            }
            plot = destination
            moveSourcePlot = nil
            persist("\(kind.name) déplacée. Sa production continue.")
            return
        }
        plot = destination
    }

    func refreshWorld() {
        guard !isUISnapshot else { return }
        let seconds = state.updateInRealTime(on: world)
        guard seconds > 0 else { return }
        save()
    }

    func nextProductionIn(at now: Date = .now) -> String {
        let previous = state.lastProductionAt ?? now
        let remainder = state.productionRemainder ?? .zero
        let rates = state.production
        var candidates: [Int] = []
        let hourlyRates = [rates.wood, rates.amber, rates.provisions]
        let fractions = [remainder.wood, remainder.amber, remainder.provisions]
        for index in hourlyRates.indices where hourlyRates[index] > 0 {
            let secondsPerUnit = (1 - fractions[index]) * 3600 / Double(hourlyRates[index])
            let remaining = secondsPerUnit - now.timeIntervalSince(previous)
            candidates.append(Int(ceil(max(0, remaining))))
        }
        guard let seconds = candidates.min() else { return "—" }
        let safe = max(0, seconds)
        return "dans \(safe / 60)m \(safe % 60)s"
    }
    private func persist(_ text: String) {
        message = text
        save()
    }
    private func save() {
        guard !isUISnapshot else { return }
        do {
            try storage.save(state)
        } catch {
            message = "Action effectuée, mais sauvegarde impossible."
        }
    }

    func refreshAfterSceneChange() { refreshWorld() }
}
