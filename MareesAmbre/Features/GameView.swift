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
                    Section(L10n.text("Votre prochaine étape", "Your next step")) {
                        Text(guideStep.title).font(.headline)
                        Text(guideStep.detail)
                        Button(L10n.text("Voir où agir", "Show me where"), action: followGuide)
                    }
                    Section(L10n.text("Votre première expédition", "Your first expedition")) {
                        Text(L10n.text("1. Développez une forêt, un champ et un gisement pour produire les trois ressources.", "1. Develop a woodland, a field and a deposit to produce all three resources."))
                        Text(L10n.text("2. Construisez la Maison des savoirs et recherchez une unité.", "2. Build the Academy and research a unit."))
                        Text(L10n.text("3. Construisez la Cour des armes et entraînez vos troupes.", "3. Build the Training Grounds and train your troops."))
                        Text(L10n.text("4. Sur la carte du monde, choisissez une faction et comparez les forces avant de partir.", "4. On the world map, select a faction and compare your strength before departing."))
                    }
                    Section(L10n.text("À savoir", "Good to know")) {
                        Text(L10n.text("La production continue pendant votre absence, jusqu’au maximum affiché. L’entrepôt augmente ce maximum.", "Production continues while you are away, up to the displayed limit. The Warehouse increases this limit."))
                        Text(L10n.text("Une scierie, une ferme ou un atelier d’ambre nécessite un champ correspondant de niveau 10. Ce bonus n’est pas nécessaire pour commencer à recruter.", "A Sawmill, Farm or Amber Workshop requires a matching resource site at level 10. This bonus is not needed to start recruiting."))
                        Text(L10n.text("Une attaque peut coûter des unités. Le butin est limité par les survivants et la place dans vos réserves. Les adversaires sont des factions simulées.", "Attacks may cost units. Loot is limited by surviving troops and available storage. Opponents are simulated factions."))
                    }
                }
                .navigationTitle(L10n.text("Premiers pas", "Getting started"))
                .toolbar { ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Fermer", "Close")) { showsGuide = false }
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
                            Text(L10n.text("Votre prochaine étape", "Your next step")).font(.title2.bold())
                            Text(guideStep.title).font(.headline)
                            Text(guideStep.detail)
                            Button(L10n.text("Ouvrir le guide", "Open guide")) { showsGuide = true }
                            Text(L10n.text("Touchez une faction sur la carte pour consulter sa défense et préparer une expédition.", "Tap a faction on the map to view its defense and prepare an expedition."))
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
                            Text(L10n.text("CHANTIER · \(job.kind.name.uppercased())", "CONSTRUCTION · \(job.kind.name.uppercased())"))
                                .font(.caption2.bold()).tracking(1.2)
                            Text(remaining > 0 ? L10n.text("Termine dans \(remaining) s", "Finishes in \(remaining) s") : L10n.text("Achèvement en cours", "Finishing construction"))
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
                    .accessibilityLabel(L10n.text("Chantier de \(job.kind.name), \(remaining) secondes restantes", "Construction of \(job.kind.name), \(remaining) seconds remaining"))
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
                Text(showsWorld ? L10n.text("L’archipel", "The Archipelago") : villageMap.title)
                    .font(.headline.bold()).fontDesign(.serif)
                    .contentTransition(.opacity)
            }
        }
        .foregroundStyle(Palette.paper)
        .accessibilityElement(children: .contain)
    }

    private var navigation: some View {
        HStack(spacing: 5) {
            navigationButton(L10n.text("Ressources", "Resources"), symbol: "leaf.fill", selected: !showsWorld && villageMap == .resourceFields) {
                selectVillageMap(.resourceFields)
            }
            navigationButton(L10n.text("Centre", "Town"), symbol: "building.2.fill", selected: !showsWorld && villageMap == .townCenter) {
                selectVillageMap(.townCenter)
            }
            navigationButton(L10n.text("Monde", "World"), symbol: "map.fill", selected: showsWorld) {
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
            return (L10n.text("Votre terrain se développe", "Your resource site is developing"), L10n.text("Le nouveau niveau sera disponible à la fin de la minute de travaux.", "The new level will be ready after one minute of work."), nil, job.plot)
        }
        for plot in [0, 2, 4] where session.state.resourceLevel(at: plot) == 0 {
            return (L10n.text("Lancez vos trois productions", "Start all three resource productions"), L10n.text("Améliorez ce champ au niveau 1. Si les ressources manquent, laissez vos productions remplir les réserves.", "Upgrade this site to level 1. If resources are low, let production replenish your stores."), nil, plot)
        }
        if let job = session.state.construction {
            return (L10n.text("Votre chantier avance", "Construction is progressing"), L10n.text("Vous pouvez consulter le temps restant ou annuler pour récupérer la moitié du coût.", "Check the remaining time or cancel to recover half the cost."), job.kind, job.plot)
        }
        if !session.state.hasBuilding(.academy) {
            return (L10n.text("Construisez la Maison des savoirs", "Build the Academy"), L10n.text("Choisissez ce bâtiment sur un lot libre du Centre.", "Choose this building on an empty town lot."), .academy, nil)
        }
        if session.state.unlockedUnits.isEmpty {
            return (L10n.text("Découvrez votre première unité", "Discover your first unit"), L10n.text("Ouvrez la Maison des savoirs pour lancer une recherche ou suivre celle en cours.", "Open the Academy to start research or follow its progress."), .academy, nil)
        }
        if !session.state.hasBuilding(.warCourt) {
            return (L10n.text("Construisez la Cour des armes", "Build the Training Grounds"), L10n.text("Ce bâtiment entraîne les unités découvertes dans la Maison des savoirs.", "This building trains units discovered at the Academy."), .warCourt, nil)
        }
        if session.state.armyPower == 0 && session.state.army?.raid == nil {
            return (L10n.text("Entraînez vos premières troupes", "Train your first troops"), L10n.text("Ouvrez la Cour des armes et recrutez plusieurs unités avant votre expédition.", "Open the Training Grounds and recruit several units before your expedition."), .warCourt, nil)
        }
        return (L10n.text("Explorez les factions voisines", "Explore neighboring factions"), L10n.text("Comparez votre force à leur défense, lancez une expédition et consultez le rapport au retour.", "Compare your strength with their defense, launch an expedition and read the report on return."), nil, nil)
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
