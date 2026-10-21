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
    private(set) var absenceSummary: AbsenceSummary?
    private(set) var state: VillageState
    private(set) var world: WorldMap
    var plot = VillageMapMode.resourceFields.initialPlot
    var guidedStep: VillageGuideStep?
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
                || ProcessInfo.processInfo.arguments.contains("--snapshot-progression")
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
            if ProcessInfo.processInfo.arguments.contains("--snapshot-progression") {
                state.buildingLevels = [.forge: 3, .warehouse: 2]
                state.weaponsLevel = nil
                state.unitWeaponLevels = [.tideguard: 1, .pillager: 0]
                state.army = ArmyState(units: [.tideguard: 20, .pillager: 8], unlockedUnits: [.tideguard, .pillager])
                state.resources = Resources(wood: 900, amber: 600, provisions: 800)
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
            if ProcessInfo.processInfo.arguments.contains("--snapshot-expansion") {
                state.buildings[12] = .hall
                for kind in [BuildingKind.academy, .warehouse, .expeditionQuay] {
                    guard !state.hasBuilding(kind) else { continue }
                    if let plot = VillageMapMode.townCenter.slots.first(where: { state.buildings[$0] == nil && VillageState.canPlace(kind, at: $0) }) {
                        state.buildings[plot] = kind
                    }
                }
                state.buildingLevels = [.hall: 5, .academy: 3, .warehouse: 3, .expeditionQuay: 2]
                state.resources = Resources(wood: 1800, amber: 1600, provisions: 1800)
                state.expansion = ExpansionProgress(researched: true, settlersReady: true)
                state.army = ArmyState(units: [.tideguard: 15], unlockedUnits: [.tideguard])
                selectedTile = state.suggestedSettlementSites(on: world).last ?? .home
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-colony"),
               state.found(at: selectedTile, role: .production, escort: .tideguard, on: world),
               let arrival = state.expansion?.voyage?.arrivesAt {
                state.updateDomain(now: arrival, on: world)
                _ = state.switchSettlement(to: selectedTile)
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-shipment"),
               state.found(at: selectedTile, role: .production, escort: .tideguard, on: world),
               let arrival = state.expansion?.voyage?.arrivesAt {
                state.updateDomain(now: arrival, on: world)
                state.resources = Resources(wood: 400, amber: 200, provisions: 350)
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-raid-report") || ProcessInfo.processInfo.arguments.contains("--snapshot-mailbox") || ProcessInfo.processInfo.arguments.contains("--snapshot-mail-detail") {
                // Use the real departure and return rules, isolated from the player's save.
                state.army = ArmyState(units: [.tideguard: 25, .pillager: 10], unlockedUnits: [.tideguard, .pillager])
                let departed = Date(timeIntervalSince1970: 1_800_000_000)
                if state.raid(targetID: 9, units: [.tideguard: 20, .pillager: 10], now: departed),
                   let returning = state.army?.raid?.returnsAt {
                    state.updateArmy(now: returning)
                }
            }

            if ProcessInfo.processInfo.arguments.contains("--snapshot-bot-attacks") {
                state.lastProductionAt = Date(timeIntervalSince1970: 1_792_358_400)
                state.scheduleBotAttacks(now: state.lastProductionAt!)
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-hero-profile") {
                _ = state.customizeHero(portrait: .captainWoman, name: "Élyne")
                state.hero?.experience = 145
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-hero-mission") {
                let date = Date(timeIntervalSince1970: 1_800_000_000)
                state.lastProductionAt = date
                _ = state.customizeHero(portrait: .captainWoman, name: "Élyne", now: date)
                state.hero?.experienceStartedAt = date
                state.hero?.experience = 0
                if ProcessInfo.processInfo.arguments.contains("--snapshot-hero-active") {
                    _ = state.startHeroMission(.discoverWreck, now: date)
                } else if ProcessInfo.processInfo.arguments.contains("--snapshot-hero-repair") {
                    state.hero?.experience = 80
                    state.hero?.missions = HeroMissions(chapter: 2, materials: 5)
                } else if ProcessInfo.processInfo.arguments.contains("--snapshot-hero-boat") {
                    state.hero?.experience = 155
                    state.hero?.missions = HeroMissions(chapter: 3, materials: 0,
                        report: HeroMissionReport(mission: .repairBoat, experience: 75, materials: 0))
                }
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-hero-equipment") {
                state.hero?.experience = 450
                state.hero?.missions = HeroMissions(chapter: 3, materials: 20,
                    equipment: HeroEquipment(spyglass: 1, outfit: 1, sail: 1))
                if ProcessInfo.processInfo.arguments.contains("--snapshot-equipment-locked") {
                    state.hero?.experience = 30
                    state.hero?.missions = HeroMissions(chapter: 1, materials: 2)
                } else if ProcessInfo.processInfo.arguments.contains("--snapshot-equipment-max") {
                    state.hero?.experience = 1000
                    state.hero?.missions?.equipment = HeroEquipment(spyglass: 3, outfit: 3, sail: 3)
                }
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-protection") {
                state.beginProtection(now: Date(timeIntervalSince1970: 1_792_358_400))
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-mailbox") || ProcessInfo.processInfo.arguments.contains("--snapshot-mail-detail") {
                let date = Date(timeIntervalSince1970: 1_800_000_000)
                state.receiveMail(.welcome, key: "welcome", at: date)
                _ = state.startCoastalCampaign()
                _ = state.advanceCoastalTide(now: date.addingTimeInterval(900))
                _ = state.advanceCoastalTide(now: date.addingTimeInterval(1800))
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-absence") {
                let start = Date(timeIntervalSince1970: 1_800_000_000)
                state.lastProductionAt = start
                state.beginProtection(now: start)
                if let warehouse = state.buildings.first(where: { $0.value == .warehouse })?.key {
                    state.construction = ConstructionJob(plot: warehouse, kind: .warehouse, startedAt: start,
                                                         duration: 60, targetLevel: 2)
                }
                state.army?.training = TrainingOrder(unit: .tideguard, count: 3, endsAt: start.addingTimeInterval(60))
                _ = state.customizeHero(portrait: .captainWoman, name: "Élyne", now: start)
                _ = state.startHeroMission(.discoverWreck, now: start)
                let before = state
                state.updateDomain(now: start.addingTimeInterval(4 * 3600), on: world)
                absenceSummary = AbsenceSummary.between(before, and: state, now: start.addingTimeInterval(4 * 3600))
            }
            if ProcessInfo.processInfo.arguments.contains("--snapshot-world-travel") || ProcessInfo.processInfo.arguments.contains("--snapshot-hero-support") {
                let date = Date.now
                _ = state.customizeHero(portrait: .captainWoman, name: "Élyne", now: date)
                state.army = ArmyState(units: [.tideguard: 20], unlockedUnits: [.tideguard])
                let support = ProcessInfo.processInfo.arguments.contains("--snapshot-hero-support")
                _ = state.raid(targetID: 6, units: [.tideguard: 10], withHero: support, now: date)
                if !support { _ = state.startHeroMission(.discoverWreck, now: date) }
            }
            return
        }
        do {
            if let saved = try storage.load(seed: seed, world: world) { state = saved }
        } catch {
            markUnreadableSave()
        }
        state.scheduleBotAttacks()
        selectedTile = state.location
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

    @discardableResult
    func upgradeHeroEquipment(_ kind: HeroEquipmentKind) -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.upgradeHeroEquipment(kind) else { return false }
        persist(String(localized: "hero.equipment.saved", defaultValue: "Équipement amélioré : \(String(kind.title))."))
        return true
    }

    @discardableResult
    func startHeroMission(_ mission: HeroMissionKind) -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.startHeroMission(mission) else { return false }
        persist(String(localized: "hero.mission.departed", defaultValue: "Mission du héros lancée. Le résultat sera disponible à son retour."))
        return true
    }

    @discardableResult
    func customizeHero(portrait: HeroPortrait, name: String) -> Bool {
        guard state.customizeHero(portrait: portrait, name: name) else { return false }
        save()
        return true
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
        state.receiveMail(.welcome, key: "welcome", at: .now)
        state.beginProtection()
        state.scheduleBotAttacks()
        persist(String(localized: "screen.village_session.value_now_watch_over_amber_harbor", defaultValue: "\(String(people.name)) veille désormais sur Port d’Ambre."))
    }

    func settlementName(at location: TileCoordinate) -> String {
        location == state.location ? state.settlementName
            : state.otherVillages?.first(where: { $0.location == location })?.settlementName ?? ""
    }

    func researchNavigation() {
        refreshWorld()
        guard state.researchNavigation() else { return }
        persist(String(localized: "expansion.research.started", defaultValue: "Recherche de navigation lancée."))
    }

    func prepareSettlers() {
        refreshWorld()
        guard state.prepareSettlers() else { return }
        persist(String(localized: "expansion.settlers.started", defaultValue: "Préparation des colons lancée."))
    }

    @discardableResult
    func foundColony(at tile: TileCoordinate, role: SettlementRole, escort: ArmyUnit) -> Bool {
        refreshWorld()
        guard state.found(at: tile, role: role, escort: escort, on: world) else { return false }
        persist(String(localized: "expansion.departed", defaultValue: "Les colons et leur escorte ont pris la mer."))
        return true
    }

    func switchSettlement(to location: TileCoordinate) {
        refreshWorld()
        guard state.switchSettlement(to: location) else { return }
        pendingBuilding = nil
        moveSourcePlot = nil
        guidedStep = nil
        plot = VillageMapMode.resourceFields.initialPlot
        selectedTile = location
        persist(String(localized: "expansion.switched", defaultValue: "Implantation sélectionnée."))
    }

    @discardableResult
    func sendShipment(to destination: TileCoordinate, cargo: Resources, units: [ArmyUnit: Int]) -> Bool {
        guard !hasUnreadableSave else { return false }
        refreshWorld()
        guard state.sendShipment(to: destination, cargo: cargo, units: units) else { return false }
        persist(String(localized: "shipment.departed", defaultValue: "Ravitaillement parti. La cargaison sera livrée à l’arrivée et l’escorte reviendra au village de départ."))
        return true
    }

    func extendProtection() {
        guard !hasUnreadableSave else { return }
        refreshWorld()
        guard state.extendProtection() else { return }
        persist(String(localized: "protection.extended", defaultValue: "La protection de tous vos villages est prolongée de 48 heures. Cette prolongation unique est consommée."))
    }

    func markMailRead(_ id: String) {
        guard !hasUnreadableSave, state.markMailRead(id) else { return }
        save()
    }

    func markAllMailRead() {
        guard !hasUnreadableSave, state.unreadMailCount > 0 else { return }
        state.markAllMailRead()
        save()
    }

    func train(_ unit: ArmyUnit, count: Int) {
        refreshWorld()
        guard state.train(unit, count: count) else { return }
        persist(String(localized: "screen.village_session.training_started_for_value_units", defaultValue: "Entraînement de \(String(count)) unité(s) lancé."))
    }

    func research(_ unit: ArmyUnit) {
        refreshWorld()
        guard state.research(unit) else { return }
        persist(String(localized: "progression.research.started", defaultValue: "Recherche lancée : \(String(unit.name)) · \(String(GameProgression.durationText(state.unitResearchDuration)))."))
    }

    @discardableResult
    func raid(_ targetID: Int, units: [ArmyUnit: Int]? = nil, withHero: Bool = false) -> Bool {
        refreshWorld()
        guard state.raid(targetID: targetID, units: units, withHero: withHero) else { return false }
        let duration = state.bots.first(where: { $0.id == targetID }).map { state.raidDuration(to: $0) } ?? state.raidDuration
        persist(String(localized: "screen.village_session.expedition_departed_returns_in_value_seconds", defaultValue: "Expédition partie. Retour dans \(String(Int(duration))) secondes."))
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
        state.awardHeroExperience()
        persist(String(localized: "screen.defense.advanced", defaultValue: "La marée a changé. Consultez la menace et le rapport de défense."))
        return true
    }

    func upgradeWeapons(for unit: ArmyUnit) {
        refreshWorld()
        guard state.upgradeWeapons(for: unit) else { return }
        persist(String(localized: "progression.weapons.started", defaultValue: "Recherche d’armes lancée pour \(String(unit.name)) · \(String(GameProgression.durationText(state.weaponUpgradeDuration(for: unit))))."))
    }

    func upgradeSelectedBuilding() {
        refreshWorld()
        guard state.upgradeBuilding(at: plot), let job = state.construction else { return }
        ConstructionActivityController.start(for: job)
        persist(String(localized: "progression.building.started", defaultValue: "\(String(job.kind.name)) : niveau \(String(job.level)) en chantier · \(String(GameProgression.durationText(job.duration)))."))
    }

    func developSelectedResource() {
        refreshWorld()
        guard state.developResource(at: plot), let kind = ResourceSiteKind.at(plot) else { return }
        if let job = state.resourceUpgrade { ConstructionActivityController.start(for: job) }
        persist(String(localized: "progression.resource.started", defaultValue: "\(String(kind.name)) : amélioration lancée · \(String(GameProgression.durationText(state.resourceUpgrade?.effectiveDuration ?? 60)))."))
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
        persist(String(localized: "progression.construction.started", defaultValue: "\(String(kind.name)) : chantier lancé · \(String(GameProgression.durationText(state.construction?.duration ?? 60)))."))
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
        state.updateDomain(now: now, on: world)
        if let summary = AbsenceSummary.between(previous, and: state, now: now) { absenceSummary = summary }
        let seconds = max(0, Int(now.timeIntervalSince(previous.lastProductionAt ?? now)))
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
        if state.settlementCount > previous.settlementCount {
            message = String(localized: "expansion.founded", defaultValue: "Votre colonie est fondée ! Retrouvez-la dans le sélecteur d’implantations ou sur la carte.")
            guidedStep = nil
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
        state.recordGuideProgress()
        if let guidedStep, VillageGuideStep.next(in: state) != guidedStep { self.guidedStep = nil }
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

    func dismissAbsenceSummary() { absenceSummary = nil }

    func observeNeighbor(_ id: Int, detail: ReconnaissanceDetail = .standard) {
        guard !hasUnreadableSave else { return }
        refreshWorld()
        if state.observeNeighbor(id, detail: detail) { save() }
    }

    func exportBackup() throws -> Data {
        guard !hasUnreadableSave else { throw CocoaError(.coderReadCorrupt) }
        refreshWorld()
        return try storage.exportBackup(state)
    }

    func validateBackup(_ data: Data) throws -> VillageState {
        try storage.validateBackup(data)
    }

    func restoreBackup(_ data: Data) throws {
        let restored = try storage.restoreBackup(data)
        ConstructionActivityController.end()
        world = WorldMap(seed: restored.seed)
        state = restored
        hasUnreadableSave = false
        absenceSummary = nil
        guidedStep = nil
        pendingBuilding = nil
        moveSourcePlot = nil
        plot = VillageMapMode.resourceFields.initialPlot
        selectedTile = restored.location
        refreshWorld()
    }

    func refreshAfterSceneChange() { refreshWorld() }
}
