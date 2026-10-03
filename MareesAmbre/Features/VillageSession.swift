import Foundation
import Observation

@MainActor @Observable
final class VillageSession {
    private(set) var state: VillageState
    let world: WorldMap
    var plot = VillageMapMode.resourceFields.initialPlot
    var selectedTile = TileCoordinate.home
    private(set) var message = String(localized: "screen.village_session.choose_an_empty_plot_to_build", defaultValue: "Choisissez un emplacement libre pour construire.")
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
            message = String(localized: "screen.village_session.the_village_save_could_not_be_read_a_new_village_is_shown_your_next_action_will_repla", defaultValue: "Sauvegarde du village illisible. Un village neuf est affiché ; la prochaine action remplacera cette sauvegarde.")
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
        persist(String(localized: "screen.village_session.value_now_watch_over_amber_harbor", defaultValue: "\(String(people.name)) veille désormais sur Port d’Ambre."))
    }

    func train(_ unit: ArmyUnit, count: Int) {
        refreshWorld()
        guard state.train(unit, count: count) else { return }
        persist(String(localized: "screen.village_session.training_started_for_value_units", defaultValue: "Entraînement de \(String(count)) unité(s) lancé."))
    }

    func research(_ unit: ArmyUnit) {
        refreshWorld()
        guard state.research(unit) else { return }
        persist(String(localized: "screen.village_session.research_started_value_ready_in_one_minute", defaultValue: "Recherche lancée : \(String(unit.name)). Fin dans une minute."))
    }

    func raid(_ targetID: Int) {
        refreshWorld()
        guard state.raid(targetID: targetID) else { return }
        persist(String(localized: "screen.village_session.expedition_departed_returns_in_value_seconds", defaultValue: "Expédition partie. Retour dans \(String(Int(state.raidDuration))) secondes."))
    }

    func developSelectedResource() {
        refreshWorld()
        guard state.developResource(at: plot), let kind = ResourceSiteKind.at(plot) else { return }
        if let job = state.resourceUpgrade { ConstructionActivityController.start(for: job) }
        persist(String(localized: "screen.village_session.value_upgrade_started_ready_in_one_minute", defaultValue: "\(String(kind.name)) : amélioration lancée. Fin dans une minute."))
    }

    func cancelResourceUpgrade() {
        refreshWorld()
        guard state.cancelResourceUpgrade() else { return }
        ConstructionActivityController.end()
        persist(String(localized: "screen.village_session.upgrade_canceled_half_the_resources_were_refunded", defaultValue: "Amélioration annulée. La moitié des ressources a été récupérée."))
    }

    func build(_ kind: BuildingKind) {
        refreshWorld()
        guard state.build(kind, at: plot) else { return }
        if let job = state.construction { ConstructionActivityController.start(for: job) }
        persist(String(localized: "screen.village_session.value_construction_started_ready_in_one_minute", defaultValue: "\(String(kind.name)) : chantier lancé. Fin dans une minute."))
    }

    func cancelConstruction() {
        refreshWorld()
        guard let job = state.cancelConstruction() else { return }
        ConstructionActivityController.end()
        persist(String(localized: "screen.village_session.construction_canceled_half_the_resources_were_refunded", defaultValue: "Chantier annulé. La moitié des ressources a été récupérée."))
        _ = job
    }

    func constructionProgress(at date: Date = .now) -> Double? {
        state.construction?.progress(at: date)
    }

    func beginPlacing(_ kind: BuildingKind) {
        pendingBuilding = kind
        moveSourcePlot = nil
        message = String(localized: "screen.village_session.choose_an_empty_plot_for_value", defaultValue: "Choisissez une parcelle libre pour \(String(kind.name.lowercased())).")
    }

    func cancelPlacement() {
        pendingBuilding = nil
        cancelMovingBuilding()
    }

    func beginMovingSelectedBuilding() {
        pendingBuilding = nil
        guard let kind = state.buildings[plot], kind != .hall else { return }
        moveSourcePlot = plot
        message = String(localized: "screen.village_session.tap_a_compatible_empty_plot_to_move_value", defaultValue: "Touchez une case libre compatible pour déplacer \(String(kind.name.lowercased())).")
    }

    func cancelMovingBuilding() {
        moveSourcePlot = nil
        message = String(localized: "screen.village_session.move_canceled", defaultValue: "Déplacement annulé.")
    }

    func selectPlot(_ destination: Int) {
        if let kind = pendingBuilding {
            guard state.canBuild(kind, at: destination) else {
                message = String(localized: "screen.village_session.choose_a_compatible_empty_plot", defaultValue: "Choisissez une parcelle libre compatible.")
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
                message = String(localized: "screen.village_session.this_building_cannot_be_placed_here", defaultValue: "Cette case ne peut pas accueillir ce bâtiment.")
                return
            }
            plot = destination
            moveSourcePlot = nil
            persist(String(localized: "screen.village_session.value_moved_production_continues", defaultValue: "\(String(kind.name)) déplacée. Sa production continue."))
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
            message = String(localized: "screen.village_session.value_completed_the_building_is_ready", defaultValue: "\(String(finished.kind.name)) terminé. Le bâtiment est prêt.")
            ConstructionActivityController.end()
        } else if let finished = previous.resourceUpgrade, state.resourceUpgrade == nil {
            message = String(localized: "screen.village_session.resource_site_upgraded_to_level_value", defaultValue: "Terrain amélioré au niveau \(String(finished.targetLevel)).")
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
        return String(localized: "screen.village_session.in_value_m_value_s", defaultValue: "dans \(String(safe / 60))m \(String(safe % 60))s")
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
            message = String(localized: "screen.village_session.action_completed_but_the_game_could_not_be_saved", defaultValue: "Action effectuée, mais sauvegarde impossible.")
        }
    }

    func refreshAfterSceneChange() { refreshWorld() }
}
