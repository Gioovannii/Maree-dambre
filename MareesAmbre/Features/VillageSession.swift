import Foundation
import Observation

@MainActor @Observable
final class VillageSession {
    static var snapshotBuilding: BuildingKind? {
        [.market, .forge, .infirmary, .expeditionQuay].first {
            ProcessInfo.processInfo.arguments.contains("--snapshot-\($0.rawValue)")
        }
    }
    static var snapshotTownPlot: Int {
        guard let kind = snapshotBuilding, let index = BuildingKind.constructible.firstIndex(of: kind) else {
            return VillageMapMode.townCenter.initialPlot
        }
        return VillageMapMode.townCenter.slots.filter { $0 != 12 }[index]
    }
    private(set) var state: VillageState
    let world: WorldMap
    var plot = VillageMapMode.resourceFields.initialPlot
    var selectedTile = TileCoordinate.home
    private(set) var message = String(localized: "screen.village_session.choose_an_empty_plot_to_build", defaultValue: "Choisissez un emplacement libre pour construire.")
    private(set) var pendingBuilding: BuildingKind?
    private(set) var moveSourcePlot: Int?
    private(set) var elapsedSeconds = 0
    private(set) var hasUnreadableSave = false
    var saveRecoveryMessage: String? { hasUnreadableSave ? message : nil }
    private let storage: VillageStorage
    private var productionTask: Task<Void, Never>?
    private let isUISnapshot: Bool

    init(storage: VillageStorage = VillageStorage()) {
        self.storage = storage
        isUISnapshot = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
        let seed = isUISnapshot ? 42 : storage.activeSeed()
        world = WorldMap(seed: seed)
        state = VillageState(seed: seed)
        if isUISnapshot {
            if ProcessInfo.processInfo.arguments.contains("--snapshot-save-recovery") {
                markUnreadableSave()
                return
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-new-village") { return }
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
            if ProcessInfo.processInfo.arguments.contains("--snapshot-developed")
                || ProcessInfo.processInfo.arguments.contains("--snapshot-raid")
                || ProcessInfo.processInfo.arguments.contains("--snapshot-commerce")
                || ProcessInfo.processInfo.arguments.contains("--snapshot-defense") || Self.snapshotBuilding != nil {
                let plots = VillageMapMode.townCenter.slots.filter { $0 != 12 }
                state.buildings = Dictionary(uniqueKeysWithValues: zip(plots, BuildingKind.constructible))
                state.buildings[12] = .hall
                state.resources = Resources(wood: 400, amber: 200, provisions: 350)
                state.resourceLevels = [0: 10, 2: 10, 4: 10]
                state.weaponsLevel = 2
                state.army = ArmyState(units: [.tideguard: 20], unlockedUnits: [.tideguard])
                if ProcessInfo.processInfo.arguments.contains("--snapshot-raid") {
                    state.army = ArmyState(units: [.tideguard: 20, .pillager: 8], unlockedUnits: [.tideguard, .pillager])
                }
                plot = Self.snapshotTownPlot
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-defense") {
                // A small garrison makes sending troops out a meaningful defensive risk.
                state.army = ArmyState(units: [.tideguard: 2, .pillager: 4], unlockedUnits: [.tideguard, .pillager])
                state.weaponsLevel = 0
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-commerce") {
                state.army = ArmyState(units: [.tideguard: 2, .pillager: 4], unlockedUnits: [.tideguard, .pillager])
                state.weaponsLevel = 0
                state.coastalCampaign = CoastalCampaign(tide: 1)
            }
            return
        }
        do {
            if let saved = try storage.load(seed: seed, world: world) { state = saved }
        } catch {
            markUnreadableSave()
        }
        refreshWorld()
        productionTask = Task { [weak self] in
            while !Task.isCancelled {
                let interval: Duration = .seconds(1)
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled, let self else { return }
                self.refreshWorld()
            }
        }
    }

    func choosePeople(_ people: People) {
        guard state.people == nil else { return }
        if hasUnreadableSave {
            do {
                if !isUISnapshot { try storage.preserveUnreadableSave(seed: state.seed) }
            } catch {
                message = String(localized: "screen.village_session.save_backup_failed", defaultValue: "Impossible de conserver une copie de la sauvegarde précédente. La nouvelle partie n’a pas été créée. Réessayez.")
                return
            }
            state = VillageState(seed: world.seed)
            hasUnreadableSave = false
        }
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

    @discardableResult
    func raid(_ targetID: Int, units: [ArmyUnit: Int]? = nil) -> Bool {
        refreshWorld()
        guard state.raid(targetID: targetID, units: units) else { return false }
        persist(String(localized: "screen.village_session.expedition_departed_returns_in_value_seconds", defaultValue: "Expédition partie. Retour dans \(String(Int(state.raidDuration))) secondes."))
        return true
    }

    func trade(from source: ResourceKind, to destination: ResourceKind, lots: Int) {
        refreshWorld()
        guard state.trade(from: source, to: destination, lots: lots) else { return }
        persist(String(localized: "screen.village_session.trade_completed", defaultValue: "Échange effectué. Les réserves ont été mises à jour."))
    }

    @discardableResult
    func sendConvoy(on route: TradeRoute, units: [ArmyUnit: Int]) -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.sendConvoy(on: route, units: units) else { return false }
        persist(String(localized: "screen.commerce.departed", defaultValue: "Convoi parti. Son escorte rejoindra le village à la marée de retour annoncée."))
        return true
    }

    @discardableResult
    func claimConvoyReward() -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.claimConvoyReward() else { return false }
        persist(String(localized: "screen.commerce.claimed", defaultValue: "Paiement du contrat ajouté aux réserves."))
        return true
    }

    @discardableResult
    func startCoastalCampaign() -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.startCoastalCampaign() else { return false }
        persist(String(localized: "screen.defense.started", defaultValue: "Les corsaires approchent. Premier assaut dans deux marées."))
        return true
    }

    @discardableResult
    func advanceCoastalTide() -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.advanceCoastalTide() else { return false }
        persist(String(localized: "screen.defense.advanced", defaultValue: "La marée a changé. Consultez la menace et le rapport de défense."))
        return true
    }

    func upgradeWeapons() {
        refreshWorld()
        guard state.upgradeWeapons() else { return }
        persist(String(localized: "screen.village_session.weapons_research_started", defaultValue: "Recherche d’armes lancée. Fin dans une minute."))
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
        guard let kind = state.buildings[plot], kind != .hall, kind != .expeditionQuay else { return }
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

    func refreshWorld(now: Date = .now) {
        guard !isUISnapshot, !hasUnreadableSave else { return }
        let previous = state
        let seconds = state.updateInRealTime(now: now, on: world)
        if previous.weaponUpgrade != nil, state.weaponUpgrade == nil {
            message = String(localized: "screen.village_session.weapons_research_complete", defaultValue: "Armes améliorées. Le bonus s’applique aux prochaines expéditions.")
        }
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
        guard !isUISnapshot, !hasUnreadableSave else { return }
        do {
            try storage.save(state)
        } catch {
            message = String(localized: "screen.village_session.action_completed_but_the_game_could_not_be_saved", defaultValue: "Action effectuée, mais sauvegarde impossible.")
        }
    }

    private func markUnreadableSave() {
        hasUnreadableSave = true
        message = String(localized: "screen.village_session.unreadable_save_recovery", defaultValue: "Votre sauvegarde est illisible. Fonder un village démarrera une nouvelle partie et conservera une copie de la sauvegarde précédente sur cet appareil.")
    }

    func refreshAfterSceneChange() { refreshWorld() }
}
