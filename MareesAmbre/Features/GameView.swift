import SwiftUI

struct GameView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showsWorld = ProcessInfo.processInfo.arguments.contains("--snapshot-world")
    @State private var showsVillageDetails = ProcessInfo.processInfo.arguments.contains("--snapshot-upgrade")
    @State private var villageMap: VillageMapMode = ProcessInfo.processInfo.arguments.contains("--snapshot-center")
        ? .townCenter : .resourceFields
    @State private var selectedResourcePlot = VillageMapMode.resourceFields.initialPlot
    @State private var selectedTownPlot = VillageMapMode.townCenter.initialPlot
    @State private var showsGuide = false
    @State private var opensGuidedPlot = false

    var body: some View {
        GeometryReader { viewport in
            if session.state.people == nil {
                PrologueView(onChoose: session.choosePeople)
            } else if viewport.size.width >= 700 && viewport.size.height >= 600 {
                tabletScreen
            } else if showsWorld {
                worldScreen
            } else {
                villageScreen
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: session.state.people) { previous, current in
            if previous == nil, current != nil { showsGuide = true }
        }
        .sheet(isPresented: $showsGuide, onDismiss: {
            if opensGuidedPlot {
                opensGuidedPlot = false
                showsVillageDetails = true
            }
        }) {
            NavigationStack {
                List {
                    Section(String(localized: "screen.game.your_next_step", defaultValue: "Votre prochaine étape")) {
                        Text(guideStep.title).font(.headline)
                        Text(guideStep.detail)
                        Button(String(localized: "screen.game.show_me_where", defaultValue: "Voir où agir"), action: followGuide)
                    }
                    Section(String(localized: "screen.game.your_first_expedition", defaultValue: "Votre première expédition")) {
                        Text(String(localized: "screen.game.1_develop_a_woodland_a_field_and_a_deposit_to_produce_all_three_resources", defaultValue: "1. Développez une forêt, un champ et un gisement pour produire les trois ressources."))
                        Text(String(localized: "screen.game.2_build_the_academy_and_research_a_unit", defaultValue: "2. Construisez la Maison des savoirs et recherchez une unité."))
                        Text(String(localized: "screen.game.3_build_the_training_grounds_and_train_your_troops", defaultValue: "3. Construisez la Cour des armes et entraînez vos troupes."))
                        Text(String(localized: "screen.game.4_on_the_world_map_select_a_faction_and_compare_your_strength_before_departing", defaultValue: "4. Sur la carte du monde, choisissez une faction et comparez les forces avant de partir."))
                    }
                    Section(String(localized: "screen.game.good_to_know", defaultValue: "À savoir")) {
                        Text(String(localized: "screen.game.production_continues_while_you_are_away_up_to_the_displayed_limit_the_warehouse_incre", defaultValue: "La production continue pendant votre absence, jusqu’au maximum affiché. L’entrepôt augmente ce maximum."))
                        Text(String(localized: "screen.game.a_sawmill_farm_or_amber_workshop_requires_a_matching_resource_site_at_level_10_this_b", defaultValue: "Une scierie, une ferme ou un atelier d’ambre nécessite un champ correspondant de niveau 10. Ce bonus n’est pas nécessaire pour commencer à recruter."))
                        Text(String(localized: "screen.game.attacks_may_cost_units_loot_is_limited_by_surviving_troops_and_available_storage_oppo", defaultValue: "Une attaque peut coûter des unités. Le butin est limité par les survivants et la place dans vos réserves. Les adversaires sont des factions simulées."))
                    }
                }
                .navigationTitle(String(localized: "screen.game.getting_started", defaultValue: "Premiers pas"))
                .toolbar { ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "screen.game.close", defaultValue: "Fermer")) { showsGuide = false }
                } }
            }
        }
    }

    private var tabletScreen: some View {
        HStack(spacing: 0) {
            Group {
                if showsWorld {
                    ScrollView {
                        WorldPanel()
                            .padding(20)
                    }
                } else {
                    VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding,
                                 onPlotSelected: {},
                                 onTownSelected: { selectVillageMap(.townCenter) },
                                 preservesMapProportions: true)
                        .id(villageMap)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            VStack(spacing: 12) {
                topControls.padding(.horizontal, 12)
                navigation.padding(.horizontal, 12)
                constructionStatus.padding(.horizontal, 12)
                if showsWorld {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "screen.game.your_next_step", defaultValue: "Votre prochaine étape")).font(.title2.bold())
                            Text(guideStep.title).font(.headline)
                            Text(guideStep.detail)
                            Button(String(localized: "screen.game.open_guide", defaultValue: "Ouvrir le guide")) { showsGuide = true }
                            Text(String(localized: "screen.game.tap_a_faction_on_the_map_to_view_its_defense_and_prepare_an_expedition", defaultValue: "Touchez une faction sur la carte pour consulter sa défense et préparer une expédition."))
                            WorldClockStatus()
                        }
                        .padding(20)
                    }
                } else {
                    PlotDetailScreen(mode: villageMap, isEmbedded: true)
                        .id(villageMap)
                }
            }
            .padding(.top, 12)
            .frame(width: 350)
            .background(Palette.ocean)
        }
        .background(Palette.ocean.ignoresSafeArea())
        .foregroundStyle(Palette.paper)
        .onAppear {
            session.plot = villageMap == .resourceFields ? selectedResourcePlot : selectedTownPlot
        }
    }

    private var villageScreen: some View {
        GeometryReader { geometry in
            ZStack {
                Palette.ocean.ignoresSafeArea()
                VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding,
                             onPlotSelected: { showsVillageDetails = true },
                             onTownSelected: { selectVillageMap(.townCenter) })
                .id(villageMap)
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    topControls
                        .frame(maxWidth: 560)
                    Spacer(minLength: 4)
                    constructionStatus
                        .frame(maxWidth: 560)
                    navigation
                        .frame(maxWidth: 560)
                }
                .padding(.horizontal, 12)
                .padding(.top, 7)
                .padding(.bottom, 6)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .task {
                if ProcessInfo.processInfo.arguments.contains("--snapshot-center") {
                    session.plot = selectedTownPlot
                }
            }
            .fullScreenCover(isPresented: $showsVillageDetails) {
                PlotDetailScreen(mode: villageMap)
            }
        }
    }

    private var constructionStatus: some View {
        Group {
            if let job = session.state.resourceUpgrade {
                ResourceUpgradeStatus(job: job)
            }
            if let job = session.state.construction {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    let remaining = max(0, Int(ceil(job.endsAt.timeIntervalSince(timeline.date))))
                    HStack(spacing: 9) {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(Palette.ocean)
                            .frame(width: 28, height: 28)
                            .background(Palette.amber, in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "screen.game.construction_value", defaultValue: "CHANTIER · \(String(job.kind.name.uppercased()))"))
                                .font(.caption2.bold()).tracking(1.2)
                            Text(remaining > 0 ? String(localized: "screen.game.finishes_in_value_s", defaultValue: "Termine dans \(String(remaining)) s") : String(localized: "screen.game.finishing_construction", defaultValue: "Achèvement en cours"))
                                .font(.caption.bold()).foregroundStyle(Palette.amber)
                        }
                        Spacer()
                        ProgressView(value: job.progress(at: timeline.date))
                            .tint(Palette.amber)
                            .frame(width: 72)
                    }
                    .foregroundStyle(Palette.paper)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 45)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay { Capsule().strokeBorder(Palette.amber.opacity(0.45), lineWidth: 1) }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(String(localized: "screen.game.construction_of_value_value_seconds_remaining", defaultValue: "Chantier de \(String(job.kind.name)), \(String(remaining)) secondes restantes"))
                }
            }
        }
    }

    private var worldScreen: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                topControls
                    .frame(maxWidth: 560)
                ScrollView {
                    WorldPanel()
                        .frame(maxWidth: 720)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)
                navigation
                    .frame(maxWidth: 560)
            }
            .padding(.horizontal, 12)
            .padding(.top, 7)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Palette.ocean.ignoresSafeArea())
        }
    }

    private var topControls: some View {
        VStack(spacing: 6) {
            ResourcesView(
                resources: session.state.resources,
                hourlyProduction: session.state.production,
                storageCapacity: session.state.storageCapacity
            )
            header
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            if showsWorld || villageMap == .townCenter {
                Text(showsWorld ? String(localized: "screen.game.the_archipelago", defaultValue: "L’archipel") : villageMap.title)
                    .font(.headline.bold()).fontDesign(.serif)
                    .contentTransition(.opacity)
            }
        }
        .foregroundStyle(Palette.paper)
        .accessibilityElement(children: .contain)
    }

    private var navigation: some View {
        HStack(spacing: 5) {
            navigationButton(String(localized: "screen.game.resources", defaultValue: "Ressources"), symbol: "leaf.fill", selected: !showsWorld && villageMap == .resourceFields) {
                selectVillageMap(.resourceFields)
            }
            navigationButton(String(localized: "screen.game.town", defaultValue: "Centre"), symbol: "building.2.fill", selected: !showsWorld && villageMap == .townCenter) {
                selectVillageMap(.townCenter)
            }
            navigationButton(String(localized: "screen.game.world", defaultValue: "Monde"), symbol: "map.fill", selected: showsWorld) {
                showsWorld = true
            }
        }
        .padding(4)
        .background(Palette.panel.opacity(0.96), in: .capsule)
    }

    private func navigationButton(_ title: String, symbol: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundStyle(selected ? Palette.ocean : Palette.muted)
                .background {
                    if selected { Capsule().fill(Palette.amber) }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func selectVillageMap(_ mode: VillageMapMode) {
        showsWorld = false
        if session.moveSourcePlot != nil || session.pendingBuilding != nil { session.cancelPlacement() }
        guard villageMap != mode else { return }
        villageMap = mode
        session.plot = mode == .resourceFields ? selectedResourcePlot : selectedTownPlot
    }

    private var selectedPlotBinding: Binding<Int> {
        switch villageMap {
        case .resourceFields: $selectedResourcePlot
        case .townCenter: $selectedTownPlot
        }
    }

    private var guideStep: (title: String, detail: String, kind: BuildingKind?, plot: Int?) {
        if let job = session.state.resourceUpgrade {
            return (String(localized: "screen.game.your_resource_site_is_developing", defaultValue: "Votre terrain se développe"), String(localized: "screen.game.the_new_level_will_be_ready_after_one_minute_of_work", defaultValue: "Le nouveau niveau sera disponible à la fin de la minute de travaux."), nil, job.plot)
        }
        for plot in [0, 2, 4] where session.state.resourceLevel(at: plot) == 0 {
            return (String(localized: "screen.game.start_all_three_resource_productions", defaultValue: "Lancez vos trois productions"), String(localized: "screen.game.upgrade_this_site_to_level_1_if_resources_are_low_let_production_replenish_your_store", defaultValue: "Améliorez ce champ au niveau 1. Si les ressources manquent, laissez vos productions remplir les réserves."), nil, plot)
        }
        if let job = session.state.construction {
            return (String(localized: "screen.game.construction_is_progressing", defaultValue: "Votre chantier avance"), String(localized: "screen.game.check_the_remaining_time_or_cancel_to_recover_half_the_cost", defaultValue: "Vous pouvez consulter le temps restant ou annuler pour récupérer la moitié du coût."), job.kind, job.plot)
        }
        if !session.state.hasBuilding(.academy) {
            return (String(localized: "screen.game.build_the_academy", defaultValue: "Construisez la Maison des savoirs"), String(localized: "screen.game.choose_this_building_on_an_empty_town_lot", defaultValue: "Choisissez ce bâtiment sur un lot libre du Centre."), .academy, nil)
        }
        if session.state.unlockedUnits.isEmpty {
            return (String(localized: "screen.game.discover_your_first_unit", defaultValue: "Découvrez votre première unité"), String(localized: "screen.game.open_the_academy_to_start_research_or_follow_its_progress", defaultValue: "Ouvrez la Maison des savoirs pour lancer une recherche ou suivre celle en cours."), .academy, nil)
        }
        if !session.state.hasBuilding(.warCourt) {
            return (String(localized: "screen.game.build_the_training_grounds", defaultValue: "Construisez la Cour des armes"), String(localized: "screen.game.this_building_trains_units_discovered_at_the_academy", defaultValue: "Ce bâtiment entraîne les unités découvertes dans la Maison des savoirs."), .warCourt, nil)
        }
        if session.state.armyPower == 0 && session.state.army?.raid == nil {
            return (String(localized: "screen.game.train_your_first_troops", defaultValue: "Entraînez vos premières troupes"), String(localized: "screen.game.open_the_training_grounds_and_recruit_several_units_before_your_expedition", defaultValue: "Ouvrez la Cour des armes et recrutez plusieurs unités avant votre expédition."), .warCourt, nil)
        }
        return (String(localized: "screen.game.explore_neighboring_factions", defaultValue: "Explorez les factions voisines"), String(localized: "screen.game.compare_your_strength_with_their_defense_launch_an_expedition_and_read_the_report_on", defaultValue: "Comparez votre force à leur défense, lancez une expédition et consultez le rapport au retour."), nil, nil)
    }

    private func followGuide() {
        let step = guideStep
        showsGuide = false
        guard step.kind != nil || step.plot != nil else { showsWorld = true; return }
        let mode: VillageMapMode = step.kind == nil ? .resourceFields : .townCenter
        let plot = step.plot ?? session.state.buildings.first(where: { $0.value == step.kind })?.key
            ?? VillageMapMode.townCenter.slots.first(where: { session.state.buildings[$0] == nil }) ?? 10
        selectVillageMap(mode)
        if mode == .resourceFields { selectedResourcePlot = plot } else { selectedTownPlot = plot }
        session.plot = plot
        opensGuidedPlot = true
    }
}

#Preview { GameView().environment(VillageSession()) }
