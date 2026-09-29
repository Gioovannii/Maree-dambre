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
                    Section("Votre prochaine étape") {
                        Text(guideStep.title).font(.headline)
                        Text(guideStep.detail)
                        Button("Voir où agir", action: followGuide)
                    }
                    Section("Votre première expédition") {
                        Text("1. Développez une forêt, un champ et un gisement pour produire les trois ressources.")
                        Text("2. Construisez la Maison des savoirs et recherchez une unité.")
                        Text("3. Construisez la Cour des armes et entraînez vos troupes.")
                        Text("4. Sur la carte du monde, choisissez une faction et comparez les forces avant de partir.")
                    }
                    Section("À savoir") {
                        Text("La production continue pendant votre absence, jusqu’au maximum affiché. L’entrepôt augmente ce maximum.")
                        Text("Une scierie, une ferme ou un atelier d’ambre nécessite un champ correspondant de niveau 10. Ce bonus n’est pas nécessaire pour commencer à recruter.")
                        Text("Une attaque peut coûter des unités. Le butin est limité par les survivants et la place dans vos réserves. Les adversaires sont des factions simulées.")
                    }
                }
                .navigationTitle("Premiers pas")
                .toolbar { ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { showsGuide = false }
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
                            Text("Votre prochaine étape").font(.title2.bold())
                            Text(guideStep.title).font(.headline)
                            Text(guideStep.detail)
                            Button("Ouvrir le guide") { showsGuide = true }
                            Text("Touchez une faction sur la carte pour consulter sa défense et préparer une expédition.")
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
                    constructionStatus
                        .frame(maxWidth: 560)
                    Spacer(minLength: 4)
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
            if let job = session.state.construction {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    let remaining = max(0, Int(ceil(job.endsAt.timeIntervalSince(timeline.date))))
                    HStack(spacing: 9) {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(Palette.ocean)
                            .frame(width: 28, height: 28)
                            .background(Palette.amber, in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHANTIER · \(job.kind.name.uppercased())")
                                .font(.caption2.bold()).tracking(1.2)
                            Text(remaining > 0 ? "Termine dans \(remaining) s" : "Achèvement en cours")
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
                    .accessibilityLabel("Chantier de \(job.kind.name), \(remaining) secondes restantes")
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
            Text(showsWorld ? "L’archipel" : villageMap.title)
                .font(.headline.bold()).fontDesign(.serif)
                .contentTransition(.opacity)
            Spacer(minLength: 2)
            Button { showsGuide = true } label: {
                Image(systemName: "book.closed.fill")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Premiers pas : \(guideStep.title)")
            Label(session.state.people?.name ?? "Veilleurs", systemImage: "sailboat.fill")
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 10).padding(.vertical, 9)
                .background(Palette.panel, in: .capsule)
        }
        .foregroundStyle(Palette.paper)
        .accessibilityElement(children: .contain)
    }

    private var navigation: some View {
        HStack(spacing: 5) {
            navigationButton("Ressources", symbol: "leaf.fill", selected: !showsWorld && villageMap == .resourceFields) {
                selectVillageMap(.resourceFields)
            }
            navigationButton("Centre", symbol: "building.2.fill", selected: !showsWorld && villageMap == .townCenter) {
                selectVillageMap(.townCenter)
            }
            navigationButton("Monde", symbol: "map.fill", selected: showsWorld) {
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
        if session.moveSourcePlot != nil { session.cancelMovingBuilding() }
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
        for plot in [0, 2, 4] where session.state.resourceLevel(at: plot) == 0 {
            return ("Lancez vos trois productions", "Améliorez ce champ au niveau 1. Si les ressources manquent, laissez vos productions remplir les réserves.", nil, plot)
        }
        if let job = session.state.construction {
            return ("Votre chantier avance", "Vous pouvez consulter le temps restant ou annuler pour récupérer la moitié du coût.", job.kind, job.plot)
        }
        if !session.state.hasBuilding(.academy) {
            return ("Construisez la Maison des savoirs", "Choisissez ce bâtiment sur un lot libre du Centre.", .academy, nil)
        }
        if session.state.unlockedUnits.isEmpty {
            return ("Découvrez votre première unité", "Ouvrez la Maison des savoirs pour lancer une recherche ou suivre celle en cours.", .academy, nil)
        }
        if !session.state.hasBuilding(.warCourt) {
            return ("Construisez la Cour des armes", "Ce bâtiment entraîne les unités découvertes dans la Maison des savoirs.", .warCourt, nil)
        }
        if session.state.armyPower == 0 && session.state.army?.raid == nil {
            return ("Entraînez vos premières troupes", "Ouvrez la Cour des armes et recrutez plusieurs unités avant votre expédition.", .warCourt, nil)
        }
        return ("Explorez les factions voisines", "Comparez votre force à leur défense, lancez une expédition et consultez le rapport au retour.", nil, nil)
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
