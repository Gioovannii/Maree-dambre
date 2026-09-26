import SwiftUI

struct GameView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showsWorld = false
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

                VStack(spacing: 10) {
                    topControls
                        .frame(maxWidth: 560)
                    Spacer(minLength: 4)
                    ScrollView(.vertical) {
                        VStack(spacing: 9) {
                            ConstructionPanel(mode: villageMap)
                            WorldClockStatus()
                        }
                        .padding(.bottom, 4)
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: min(370, max(210, geometry.size.height * 0.48)))
                    .frame(maxWidth: 620)
                }
                .padding(.horizontal, 12)
                .padding(.top, 7)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            }
            .padding(.horizontal, 12)
            .padding(.top, 7)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Palette.ocean.ignoresSafeArea())
        }
    }

    private var topControls: some View {
        VStack(spacing: 8) {
            header
            ResourcesView(
                resources: session.state.resources,
                hourlyProduction: session.state.production,
                storageCapacity: session.state.storageCapacity
            )
            navigation
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("LES MARÉES D’AMBRE")
                    .font(.caption2.bold()).tracking(1.5).foregroundStyle(Palette.amber)
                Text(showsWorld ? "L’archipel" : "Port d’Ambre")
                    .font(.title2.bold()).fontDesign(.serif)
                    .contentTransition(.opacity)
            }
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
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 42)
                .foregroundStyle(selected ? Palette.ocean : Palette.muted)
                .background {
                    if selected { Capsule().fill(Palette.amber) }
                }
        }
        .buttonStyle(.plain)
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
