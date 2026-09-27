import SwiftUI

struct VillageBoard: View {
    let mode: VillageMapMode
    @Binding var selectedPlot: Int
    let onPlotSelected: () -> Void
    let onTownSelected: () -> Void
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
                        .saturation(mode == .resourceFields ? 0.82 : 1)
                        .contrast(mode == .resourceFields ? 0.88 : 1)
                        .blur(radius: mode == .resourceFields ? 1.3 : 0)
                        .clipped()
                        .accessibilityHidden(true)

                    VillageAmbience(mode: mode)
                        .frame(width: mapSide, height: mapSide)
                        .accessibilityHidden(true)

                    ForEach(mode.slots, id: \.self) { plot in
                        plotButton(plot, mapSide: mapSide)
                            .position(position(for: plot, in: mapSize))
                            .zIndex(Double(plot / 5 + plot % 5))
                    }

                    if mode == .resourceFields {
                        Button(action: onTownSelected) {
                            Label("Quais & Centre", systemImage: "sailboat.fill")
                                .font(.caption.bold())
                                .foregroundStyle(Palette.paper)
                                .padding(.horizontal, 11)
                                .frame(minHeight: 38)
                                .background(Palette.panel.opacity(0.92), in: .capsule)
                                .overlay { Capsule().strokeBorder(Palette.amber.opacity(0.8), lineWidth: 1.5) }
                        }
                        .buttonStyle(.plain)
                        .position(x: mapSide * 0.50, y: mapSide * 0.54)
                        .zIndex(100)
                        .accessibilityHint("Ouvrir le port et les bâtiments du Centre-ville")
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

    private func plotButton(_ plot: Int, mapSide: CGFloat) -> some View {
        let building = session.state.buildings[plot]
        let selected = session.plot == plot
        let terrain = VillageState.ground(at: plot)
        let site = mode == .resourceFields ? ResourceSiteKind.at(plot) : nil
        let siteLevel = session.state.resourceLevel(at: plot)
        let isUnavailable = mode == .townCenter && building == nil && !BuildingKind.constructible(in: mode).contains { $0.suits(terrain) }
        let size = min(180, max(96, mapSide * 0.20))
        let footprintWidth = size * 0.82
        let footprintHeight = size * 0.34
        let canReceiveMovingBuilding = session.moveSourcePlot.map {
            building == nil && session.state.canMoveBuilding(from: $0, to: plot)
        } ?? false

        return Button {
            let isMoving = session.moveSourcePlot != nil
            session.selectPlot(plot)
            selectedPlot = session.plot
            if !isMoving { onPlotSelected() }
        } label: {
            ZStack {
                if let site {
                    TideLevelBadge(level: siteLevel, symbol: site.symbol)
                        .overlay {
                            if selected {
                                RoundedRectangle(cornerRadius: 9)
                                    .strokeBorder(Palette.amber, lineWidth: 2.5)
                            }
                        }
                        .shadow(color: selected ? Palette.amber.opacity(0.6) : .clear, radius: 6)
                        .accessibilityHidden(true)
                } else if let building, building != .hall {
                    Ellipse()
                        .fill(.black.opacity(0.20))
                        .frame(width: footprintWidth, height: footprintHeight)
                        .offset(y: size * 0.30)
                    BuildingArt(kind: building)
                        .frame(width: size, height: size)
                        .overlay(alignment: .bottom) {
                            TideLevelBadge(level: 1)
                                .offset(y: -size * 0.01)
                                .accessibilityHidden(true)
                        }
                        .offset(y: -size * 0.20)
                        .accessibilityHidden(true)
                } else if building == nil && site == nil {
                    Ellipse()
                        .fill(isUnavailable ? .black.opacity(0.28) : Palette.paper.opacity(0.17))
                        .frame(width: footprintWidth, height: footprintHeight)
                        .overlay {
                            Ellipse()
                                .strokeBorder(
                                    isUnavailable ? Palette.muted.opacity(0.45) : Palette.paper.opacity(0.82),
                                    style: StrokeStyle(lineWidth: 2, dash: [6, 5])
                                )
                        }
                        .offset(y: size * 0.14)
                    Image(systemName: isUnavailable ? "lock.fill" : "plus")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(isUnavailable ? Palette.muted : Palette.ocean)
                        .frame(width: 40, height: 40)
                        .background(isUnavailable ? Palette.panel : Palette.paper, in: Circle())
                        .offset(y: size * 0.14)
                }

                if selected || session.moveSourcePlot == plot || canReceiveMovingBuilding {
                    if site == nil {
                        Ellipse()
                            .strokeBorder(
                                canReceiveMovingBuilding ? .green : Palette.amber,
                                lineWidth: selected || session.moveSourcePlot == plot ? 3 : 2
                            )
                            .frame(width: footprintWidth, height: footprintHeight)
                            .shadow(color: (canReceiveMovingBuilding ? Color.green : Palette.amber).opacity(0.7), radius: 8)
                            .offset(y: size * (building == nil ? 0.14 : 0.30))
                    }
                }
            }
            .frame(width: size, height: size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(site.map { "Zone \(mode.slotNumber(for: plot) ?? 0), \($0.name), niveau \(siteLevel)" }
            ?? "Emplacement \(mode.slotNumber(for: plot) ?? 0), \(building?.name ?? terrain.name)\(isUnavailable ? ", indisponible" : "")")
        .accessibilityValue(selected ? "Sélectionné" : "")
        .accessibilityHint(session.moveSourcePlot == nil
            ? (site == nil ? "Afficher les détails ou construire sur cet emplacement" : "Afficher la production et améliorer cette zone")
            : "Déplacer le bâtiment sélectionné vers cette case si elle est compatible")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func position(for plot: Int, in size: CGSize) -> CGPoint {
        let point = mode.mapPoint(for: plot)
        return CGPoint(x: size.width * point.x, y: size.height * point.y)
    }

    private func limitedOffset(_ offset: CGSize, viewport: CGSize, map: CGSize) -> CGSize {
        CGSize(
            width: min(0, max(viewport.width - map.width, offset.width)),
            height: min(0, max(viewport.height - map.height, offset.height))
        )
    }

}
