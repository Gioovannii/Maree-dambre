import SwiftUI

struct VillageBoard: View {
    let mode: VillageMapMode
    @Binding var selectedPlot: Int
    @Environment(VillageSession.self) private var session
    @State private var pan = CGSize.zero
    @GestureState private var dragTranslation = CGSize.zero

    private let mapZoom: CGFloat = 0.95

    var body: some View {
        GeometryReader { viewport in
            let viewSize = viewport.size
            let zoom = viewSize.width > 600 ? 1.00 : mapZoom
            let mapSide = max(viewSize.width, viewSize.height) * zoom
            let mapSize = CGSize(width: mapSide, height: mapSide)
            let focusX = 0.50 + CGFloat(mode.focus.east) * 0.36
            let focusY = 0.35 - CGFloat(mode.focus.north) * 0.27
            let focusedOffset = CGSize(
                width: (viewSize.width - mapSide) / 2 + (0.50 - focusX) * mapSide,
                height: (viewSize.height - mapSide) / 2 + (0.50 - focusY) * mapSide
            )
            let mapOffset = limitedOffset(
                CGSize(
                    width: focusedOffset.width + pan.width + dragTranslation.width,
                    height: focusedOffset.height + pan.height + dragTranslation.height
                ),
                viewport: viewSize,
                map: mapSize
            )

            ZStack(alignment: .topLeading) {
                ZStack {
                    Image(mode.assetName)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                        .frame(width: mapSide, height: mapSide)
                        .clipped()
                        .accessibilityHidden(true)

                    VillageAmbience(mode: mode)
                        .frame(width: mapSide, height: mapSide)
                        .accessibilityHidden(true)

                    ForEach(mode.slots, id: \.self) { plot in
                        plotButton(plot)
                            .position(position(for: plot, in: mapSize))
                            .zIndex(Double(plot / 5 + plot % 5))
                    }
                }
                .frame(width: mapSide, height: mapSide)
                .offset(mapOffset)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10)
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            let finalOffset = limitedOffset(
                                CGSize(
                                    width: focusedOffset.width + pan.width + value.translation.width,
                                    height: focusedOffset.height + pan.height + value.translation.height
                                ),
                                viewport: viewSize,
                                map: mapSize
                            )
                            pan = CGSize(
                                width: finalOffset.width - focusedOffset.width,
                                height: finalOffset.height - focusedOffset.height
                            )
                        }
                )
            }
            .frame(width: viewSize.width, height: viewSize.height, alignment: .topLeading)
            .clipped()
            .clipShape(.rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Carte du district : \(mode.title). Faites glisser pour explorer.")
    }

    private func plotButton(_ plot: Int) -> some View {
        let building = session.state.buildings[plot]
        let selected = session.plot == plot
        let terrain = VillageState.ground(at: plot)

        return Button {
            session.selectPlot(plot)
            selectedPlot = session.plot
        } label: {
            ZStack {
                if let building, building != .hall {
                    BuildingArt(kind: building)
                        .frame(width: 68, height: 70)
                        .offset(y: -16)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: building.symbol)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Palette.ocean)
                                .padding(5)
                                .background(Palette.amber, in: Circle())
                                .offset(x: 3, y: -6)
                        }
                        .allowsHitTesting(false)
                }

                if building == nil {
                    Circle()
                        .fill(.black.opacity(mode == .resourceFields ? 0.68 : 0.54))
                        .frame(width: 30, height: 30)
                    Circle()
                        .strokeBorder(.white.opacity(0.65), lineWidth: 1)
                        .frame(width: 30, height: 30)
                    Image(systemName: slotSymbol(for: plot, terrain: terrain))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(mode == .resourceFields ? resourceColor(for: terrain) : Palette.amber)
                }

                if session.moveSourcePlot == plot {
                    Circle()
                        .strokeBorder(Palette.amber, lineWidth: 3)
                        .frame(width: 48, height: 48)
                        .shadow(color: Palette.amber.opacity(0.8), radius: 10)
                } else if let source = session.moveSourcePlot, building == nil,
                          session.state.canMoveBuilding(from: source, to: plot) {
                    Circle()
                        .strokeBorder(Color.green.opacity(0.95), lineWidth: 3)
                        .frame(width: 46, height: 46)
                        .shadow(color: .green.opacity(0.75), radius: 8)
                }

                if selected {
                    Circle()
                        .fill(.black.opacity(0.58))
                        .frame(width: 36, height: 36)
                    Circle()
                        .strokeBorder(Palette.amber, lineWidth: 2.5)
                        .frame(width: 42, height: 42)
                        .shadow(color: Palette.amber.opacity(0.65), radius: 8)
                    Image(systemName: building?.symbol ?? "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Palette.amber)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode == .resourceFields ? "Champ" : "Emplacement") \(mode.slotNumber(for: plot) ?? 0), \(building?.name ?? terrain.name)")
        .accessibilityValue(selected ? "Sélectionné" : "")
        .accessibilityHint(session.moveSourcePlot == nil
            ? "Afficher les détails ou construire sur cet emplacement"
            : "Déplacer le bâtiment sélectionné vers cette case si elle est compatible")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func position(for plot: Int, in size: CGSize) -> CGPoint {
        let position = SettlementLayout.position(for: plot)
        return CGPoint(
            x: size.width * (0.50 + CGFloat(position.east) * 0.36),
            y: size.height * (0.35 - CGFloat(position.north) * 0.27)
        )
    }

    private func limitedOffset(_ offset: CGSize, viewport: CGSize, map: CGSize) -> CGSize {
        CGSize(
            width: min(0, max(viewport.width - map.width, offset.width)),
            height: min(0, max(viewport.height - map.height, offset.height))
        )
    }

    private func slotSymbol(for plot: Int, terrain: Terrain) -> String {
        if mode == .townCenter { return "plus" }
        if let building = session.state.buildings[plot] { return building.symbol }
        return switch terrain {
        case .forest: "tree.fill"
        case .amber: "sparkles"
        case .meadow: "leaf.fill"
        case .sea: "water.waves"
        }
    }

    private func resourceColor(for terrain: Terrain) -> Color {
        switch terrain {
        case .forest: Color(red: 0.59, green: 0.88, blue: 0.61)
        case .amber: Palette.amber
        case .meadow: Color(red: 0.94, green: 0.84, blue: 0.49)
        case .sea: Palette.muted
        }
    }
}
