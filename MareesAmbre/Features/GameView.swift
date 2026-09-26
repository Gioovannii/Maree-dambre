import SwiftUI

struct GameView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showsWorld = false
    @State private var showsVillageDetails = false
    @State private var villageMap: VillageMapMode = .townCenter
    @State private var selectedResourcePlot = VillageMapMode.resourceFields.initialPlot
    @State private var selectedTownPlot = VillageMapMode.townCenter.initialPlot

    var body: some View {
        Group {
            if session.state.people == nil {
                PrologueView(onChoose: session.choosePeople)
            } else if showsWorld {
                worldScreen
            } else {
                villageScreen
            }
        }
        .preferredColorScheme(.dark)
    }

    private var villageScreen: some View {
        GeometryReader { geometry in
            ZStack {
                Palette.ocean.ignoresSafeArea()
                VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding)
                    .id(villageMap)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                VStack(spacing: 8) {
                    topControls
                        .frame(maxWidth: 560)
                    Spacer(minLength: 4)
                    selectedSettlementAction
                        .frame(maxWidth: 560)
                    navigation
                        .frame(maxWidth: 560)
                }
                .padding(.horizontal, 12)
                .padding(.top, 7)
                .padding(.bottom, 6)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .sheet(isPresented: $showsVillageDetails) {
                ScrollView(.vertical) {
                    VStack(spacing: 10) {
                        ConstructionPanel(mode: villageMap)
                        WorldClockStatus()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Palette.ocean)
            }
        }
    }

    private var selectedSettlementAction: some View {
        let building = session.state.buildings[session.plot]
        let terrain = VillageState.ground(at: session.plot)
        let isUnavailable = building == nil && !BuildingKind.constructible(in: villageMap).contains { $0.suits(terrain) }
        let title = building?.name ?? (isUnavailable ? "Emplacement indisponible" : "Choisir un bâtiment")

        return Button {
            showsVillageDetails = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: building?.symbol ?? (isUnavailable ? "lock.fill" : "hammer.fill"))
                    .font(.subheadline.bold())
                    .foregroundStyle(Palette.ocean)
                    .frame(width: 32, height: 32)
                    .background(Palette.amber, in: Circle())
                Text(title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 4)
                Image(systemName: "chevron.up")
                    .font(.caption.bold())
                    .foregroundStyle(Palette.amber)
            }
            .foregroundStyle(Palette.paper)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Palette.panel.opacity(0.94), in: .capsule)
            .overlay { Capsule().strokeBorder(.white.opacity(0.1), lineWidth: 1) }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(building.map { "Détails de \($0.name)" } ?? (isUnavailable ? "Emplacement indisponible" : "Choisir un bâtiment pour cette case"))
        .accessibilityHint("Ouvrir les détails du terrain, les constructions et la production")
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
            Label(session.state.people?.name ?? "Veilleurs", systemImage: "sailboat.fill")
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 10).padding(.vertical, 9)
                .background(Palette.panel, in: .capsule)
        }
        .foregroundStyle(Palette.paper)
        .accessibilityElement(children: .combine)
    }

    private var navigation: some View {
        HStack(spacing: 5) {
            navigationButton("Champs", symbol: "leaf.fill", selected: !showsWorld && villageMap == .resourceFields) {
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
}

#Preview { GameView().environment(VillageSession()) }
