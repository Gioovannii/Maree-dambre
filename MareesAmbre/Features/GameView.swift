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
            } else {
                gameInterface
            }
        }
        .preferredColorScheme(.dark)
    }

    private var gameInterface: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    ResourcesView(
                        resources: session.state.resources,
                        hourlyProduction: session.state.production,
                        storageCapacity: session.state.storageCapacity
                    )
                    navigation

                    if showsWorld {
                        WorldPanel()
                    } else {
                        villageMapPicker
                        if geometry.size.width > 760 && !typeSize.isAccessibilitySize {
                            HStack(alignment: .top, spacing: 18) {
                                VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding)
                                    .id(villageMap)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 460)
                                ConstructionPanel(mode: villageMap).frame(width: 340)
                            }
                        } else {
                            VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding)
                                .id(villageMap)
                                .frame(height: 310)
                            ConstructionPanel(mode: villageMap)
                        }
                    }

                    WorldClockStatus()
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 28)
                .frame(maxWidth: 1120)
                .frame(maxWidth: .infinity)
            }
            .background(Palette.ocean.ignoresSafeArea())
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("LES MARÉES D’AMBRE")
                    .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                Text(showsWorld ? "L’archipel" : "Port d’Ambre")
                    .font(.largeTitle.bold()).fontDesign(.serif)
                    .contentTransition(.opacity)
            }
            Spacer(minLength: 4)
            Label(session.state.people?.name ?? "Veilleurs", systemImage: "sailboat.fill")
                .font(.subheadline.bold())
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Palette.panel, in: .capsule)
        }
        .foregroundStyle(Palette.paper)
        .accessibilityElement(children: .combine)
    }

    private var navigation: some View {
        HStack(spacing: 8) {
            navigationButton("Mon village", symbol: "house.fill", selected: !showsWorld) { showsWorld = false }
            navigationButton("Explorer", symbol: "safari.fill", selected: showsWorld) { showsWorld = true }
        }
        .padding(5)
        .background(Palette.panel, in: .capsule)
    }

    private var villageMapPicker: some View {
        HStack(spacing: 8) {
            ForEach(VillageMapMode.allCases) { mode in
                let selected = villageMap == mode
                Button {
                    guard villageMap != mode else { return }
                    villageMap = mode
                    session.plot = mode == .resourceFields ? selectedResourcePlot : selectedTownPlot
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: mode.symbol)
                        Text(mode.title)
                        Text("\(mode.slots.count)")
                            .font(.caption.monospacedDigit())
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(selected ? Palette.ocean.opacity(0.16) : .white.opacity(0.07), in: .capsule)
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(selected ? Palette.ocean : Palette.muted)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(selected ? Palette.amber : Palette.panel, in: .capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Palette.panel, in: .capsule)
    }

    private func navigationButton(_ title: String, symbol: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(selected ? Palette.ocean : Palette.muted)
                .background {
                    if selected { Capsule().fill(Palette.amber) }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var selectedPlotBinding: Binding<Int> {
        switch villageMap {
        case .resourceFields: $selectedResourcePlot
        case .townCenter: $selectedTownPlot
        }
    }
}

#Preview { GameView().environment(VillageSession()) }
