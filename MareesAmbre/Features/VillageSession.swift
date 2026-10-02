import Foundation
import Observation

@MainActor @Observable
final class VillageSession {
    private(set) var state: VillageState
    let world: WorldMap
    var plot = VillageMapMode.resourceFields.initialPlot
    var selectedTile = TileCoordinate.home
    private(set) var message = L10n.text("Choisissez un emplacement libre pour construire.", "Choose an empty plot to build.")
    private(set) var pendingBuilding: BuildingKind?
    private(set) var moveSourcePlot: Int?
    private(set) var elapsedSeconds = 0
    private let storage = VillageStorage()
    private var productionTask: Task<Void, Never>?
    private let isUISnapshot: Bool

    init() {
        isUISnapshot = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
        let seed = isUISnapshot ? 42 : storage.activeSeed()
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
            if ProcessInfo.processInfo.arguments.contains("--snapshot-construction") {
                state.construction = ConstructionJob(plot: 14, kind: .academy, startedAt: .now.addingTimeInterval(-30), duration: 60)
            }
            return
        }
        do {
            if let saved = try storage.load(seed: seed, world: world) { state = saved }
        } catch {
            message = L10n.text("Sauvegarde du village illisible. Un village neuf est affiché ; la prochaine action remplacera cette sauvegarde.", "The village save could not be read. A new village is shown; your next action will replace this save.")
        }
        refreshWorld()
        productionTask = Task { [weak self] in
            while !Task.isCancelled {
                let interval: Duration = .seconds(1)
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled else { return }
                self?.refreshWorld()
            }
        }
    }

    func choosePeople(_ people: People) {
        guard state.people == nil else { return }
        state.people = people
        persist(L10n.text("\(people.name) veille désormais sur Port d’Ambre.", "\(people.name) now watch over Amber Harbor."))
    }

    func train(_ unit: ArmyUnit, count: Int) {
        refreshWorld()
        guard state.train(unit, count: count) else { return }
        persist(L10n.text("Entraînement de \(count) unité(s) lancé.", "Training started for \(count) units."))
    }

    func research(_ unit: ArmyUnit) {
        refreshWorld()
        guard state.research(unit) else { return }
        persist(L10n.text("Recherche lancée : \(unit.name). Fin dans une minute.", "Research started: \(unit.name). Ready in one minute."))
    }

    func raid(_ targetID: Int) {
        refreshWorld()
        guard state.raid(targetID: targetID) else { return }
        persist(L10n.text("Expédition partie. Retour dans \(Int(state.raidDuration)) secondes.", "Expedition departed. Returns in \(Int(state.raidDuration)) seconds."))
    }

    func developSelectedResource() {
        refreshWorld()
        guard state.developResource(at: plot), let kind = ResourceSiteKind.at(plot) else { return }
        if let job = state.resourceUpgrade { ConstructionActivityController.start(for: job) }
        persist(L10n.text("\(kind.name) : amélioration lancée. Fin dans une minute.", "\(kind.name): upgrade started. Ready in one minute."))
    }

    func cancelResourceUpgrade() {
        refreshWorld()
        guard state.cancelResourceUpgrade() else { return }
        ConstructionActivityController.end()
        persist(L10n.text("Amélioration annulée. La moitié des ressources a été récupérée.", "Upgrade canceled. Half the resources were refunded."))
    }

    func build(_ kind: BuildingKind) {
        refreshWorld()
        guard state.build(kind, at: plot) else { return }
        if let job = state.construction { ConstructionActivityController.start(for: job) }
        persist(L10n.text("\(kind.name) : chantier lancé. Fin dans une minute.", "\(kind.name): construction started. Ready in one minute."))
    }

    func cancelConstruction() {
        refreshWorld()
        guard let job = state.cancelConstruction() else { return }
        ConstructionActivityController.end()
        persist(L10n.text("Chantier annulé. La moitié des ressources a été récupérée.", "Construction canceled. Half the resources were refunded."))
        _ = job
    }

    func constructionProgress(at date: Date = .now) -> Double? {
        state.construction?.progress(at: date)
    }

    func beginPlacing(_ kind: BuildingKind) {
        pendingBuilding = kind
        moveSourcePlot = nil
        message = L10n.text("Choisissez une parcelle libre pour \(kind.name.lowercased()).", "Choose an empty plot for \(kind.name).")
    }

    func cancelPlacement() {
        pendingBuilding = nil
        cancelMovingBuilding()
    }

    func beginMovingSelectedBuilding() {
        pendingBuilding = nil
        guard let kind = state.buildings[plot], kind != .hall else { return }
        moveSourcePlot = plot
        message = L10n.text("Touchez une case libre compatible pour déplacer \(kind.name.lowercased()).", "Tap a compatible empty plot to move \(kind.name).")
    }

    func cancelMovingBuilding() {
        moveSourcePlot = nil
        message = L10n.text("Déplacement annulé.", "Move canceled.")
    }

    func selectPlot(_ destination: Int) {
        if let kind = pendingBuilding {
            guard state.canBuild(kind, at: destination) else {
                message = L10n.text("Choisissez une parcelle libre compatible.", "Choose a compatible empty plot.")
                return
            }
            plot = destination
            build(kind)
            if state.construction?.plot == destination { pendingBuilding = nil }
            return
        }
        if let source = moveSourcePlot {
            guard state.moveBuilding(from: source, to: destination),
                  let kind = state.buildings[destination] else {
                message = L10n.text("Cette case ne peut pas accueillir ce bâtiment.", "This building cannot be placed here.")
                return
            }
            plot = destination
            moveSourcePlot = nil
            persist(L10n.text("\(kind.name) déplacée. Sa production continue.", "\(kind.name) moved. Production continues."))
            return
        }
        plot = destination
    }

    func refreshWorld() {
        guard !isUISnapshot else { return }
        let previous = state
        let seconds = state.updateInRealTime(on: world)
        if let finished = previous.construction,
           state.construction == nil,
           state.buildings[finished.plot] == finished.kind {
            message = L10n.text("\(finished.kind.name) terminé. Le bâtiment est prêt.", "\(finished.kind.name) completed. The building is ready.")
            ConstructionActivityController.end()
        } else if let finished = previous.resourceUpgrade, state.resourceUpgrade == nil {
            message = L10n.text("Terrain amélioré au niveau \(finished.targetLevel).", "Resource site upgraded to level \(finished.targetLevel).")
            ConstructionActivityController.end()
        } else if state.construction == nil && state.resourceUpgrade == nil {
            ConstructionActivityController.end()
        }
        guard seconds > 0 || state != previous else { return }
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
            let remaining = secondsPerUnit - (isUISnapshot ? 0 : now.timeIntervalSince(previous))
            candidates.append(Int(ceil(max(0, remaining))))
        }
        guard let seconds = candidates.min() else { return "—" }
        let safe = max(0, seconds)
        return L10n.text("dans \(safe / 60)m \(safe % 60)s", "in \(safe / 60)m \(safe % 60)s")
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
            message = L10n.text("Action effectuée, mais sauvegarde impossible.", "Action completed, but the game could not be saved.")
        }
    }

    func refreshAfterSceneChange() { refreshWorld() }
}
