import Foundation
import Observation

@MainActor @Observable
final class VillageSession {
    private(set) var state: VillageState
    let world: WorldMap
    var plot = 12
    var selectedTile = TileCoordinate.home
    private(set) var message = "Choisissez un emplacement libre pour construire."
    private(set) var moveSourcePlot: Int?
    private(set) var elapsedSeconds = 0
    private let storage = VillageStorage()
    private var productionTask: Task<Void, Never>?

    init() {
        let seed = WeeklyChallenge.seed(for: .now)
        world = WorldMap(seed: seed)
        state = VillageState(seed: seed)
        do {
            if let saved = try storage.load(seed: seed) { state = saved }
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
        do {
            try storage.save(state)
        } catch {
            message = "Action effectuée, mais sauvegarde impossible."
        }
    }

    func refreshAfterSceneChange() { refreshWorld() }
}
