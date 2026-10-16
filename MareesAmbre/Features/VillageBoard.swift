import SwiftUI

struct VillageBoard: View {
    let mode: VillageMapMode
    @Binding var selectedPlot: Int
    let onPlotSelected: () -> Void
    let onTownSelected: () -> Void
    var preservesMapProportions = false
    @Environment(VillageSession.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: 12) {
                if session.moveSourcePlot != nil {
                    Text(session.message).font(.body).foregroundStyle(Palette.amber)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(String(localized: "screen.construction.cancel_move", defaultValue: "Annuler le déplacement")) {
                        session.cancelMovingBuilding()
                    }
                    .buttonStyle(.bordered)
                    .tint(Palette.amber)
                }
                ForEach(visibleSlots, id: \.self) { plot in
                    plotButton(plot, mapWidth: 0)
                }
            }
        } else {
            GeometryReader { viewport in
                let viewSize = viewport.size
                let fittedWidth = min(viewSize.width, viewSize.height * 0.52)
                let mapSize = preservesMapProportions ? CGSize(width: fittedWidth, height: fittedWidth / 0.52) : CGSize(
                    width: viewSize.width > viewSize.height ? min(viewSize.width, viewSize.height * 0.52) : viewSize.width,
                    height: viewSize.height
                )

                ZStack {
                    if preservesMapProportions || viewSize.width > viewSize.height {
                        Image(mode.assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: viewSize.width, height: viewSize.height)
                            .blur(radius: 24)
                            .overlay(Palette.ocean.opacity(0.25))
                            .clipped()
                            .accessibilityHidden(true)
                    }

                    ZStack {
                        CoastalDomainScene(mode: mode)
                            .frame(width: mapSize.width, height: mapSize.height)

                        if mode == .townCenter {
                            VillagePedestrians()
                        }

                        ForEach(visibleSlots, id: \.self) { plot in
                            plotButton(plot, mapWidth: mapSize.width, mapHeight: mapSize.height)
                                .position(position(for: plot, in: mapSize))
                                .zIndex(mode == .resourceFields ? Double(mode.mapPoint(for: plot).y) : Double(plot / 5 + plot % 5))
                        }

                        if mode == .resourceFields {
                            Button(action: onTownSelected) {
                                Label(String(localized: "screen.village_board.quay_town", defaultValue: "Quais & Centre"), systemImage: "sailboat.fill")
                                    .font(.caption.bold())
                                    .foregroundStyle(Palette.paper)
                                    .padding(.horizontal, 11)
                                    .frame(minHeight: 38)
                                    .background(Palette.panel, in: .capsule)
                                    .overlay { Capsule().strokeBorder(Palette.amber.opacity(0.8), lineWidth: 1.5) }
                            }
                            .buttonStyle(.plain)
                            .position(x: mapSize.width * 0.50, y: mapSize.height * 0.86)
                            .zIndex(100)
                            .accessibilityHint(String(localized: "screen.village_board.open_the_harbor_and_town_buildings", defaultValue: "Ouvrir le port et les bâtiments du Centre-ville"))
                        }
                    }
                    .frame(width: mapSize.width, height: mapSize.height)
                }
                .frame(width: viewSize.width, height: viewSize.height)
                .clipped()
            }
        }
    }

    private var visibleSlots: [Int] {
        mode.slots.filter {
            mode.defaultVisibleSlots.contains($0) || session.state.buildings[$0] != nil
                || session.state.construction?.plot == $0
        }
    }

    private func plotButton(_ plot: Int, mapWidth: CGFloat, mapHeight: CGFloat = .infinity) -> some View {
        let building = session.state.buildings[plot]
        let construction = session.state.construction?.plot == plot ? session.state.construction : nil
        let selected = session.plot == plot
        let terrain = VillageState.ground(at: plot)
        let site = mode == .resourceFields ? ResourceSiteKind.at(plot) : nil
        let siteLevel = session.state.resourceLevel(at: plot)
        let isUnavailable = mode == .townCenter && building == nil
            && !BuildingKind.constructible(in: mode).contains { $0.suits(terrain) }
        // Larger landmarks and smaller, lower badges expose the building silhouettes.
        let baseSize = mode == .townCenter
            ? min(120, max(74, mapWidth * 0.25))
            : min(112, max(44, min(mapWidth * 0.24, mapHeight * 0.11)))
        let size = baseSize * (building == .hall ? 1.2 : 1.0)
        let footprintWidth = size * 0.82
        let footprintHeight = size * 0.34
        let canReceiveMovingBuilding = (session.pendingBuilding.map { session.state.canBuild($0, at: plot) } ?? false) || (session.moveSourcePlot.map {
            building == nil && session.state.canMoveBuilding(from: $0, to: plot)
        } ?? false)
        return Button {
            selectPlot(plot)
        } label: {
            if typeSize.isAccessibilitySize {
                Text(plotAccessibilityLabel(for: plot))
                    .font(.body)
                    .foregroundStyle(Palette.paper)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.panel, in: .rect(cornerRadius: 16))
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(accessibilityBorderColor(selected: selected, canReceive: canReceiveMovingBuilding), lineWidth: 2)
                    }
            } else {
                ZStack {
                    if site == nil && canReceiveMovingBuilding {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.62, green: 0.49, blue: 0.30).opacity(0.65))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(selected ? Palette.amber : Palette.paper.opacity(0.65), lineWidth: selected ? 3 : 1)
                        }
                        .frame(width: size, height: size * 0.72)
                    }
                    if site != nil {
                        ResourcePlotMarker(
                            level: siteLevel, selected: selected,
                            size: size,
                            upgrade: session.state.resourceUpgrade.flatMap { $0.plot == plot ? $0 : nil }
                        )
                        .accessibilityHidden(true)
                    } else if let construction {
                        TimelineView(.periodic(from: .now, by: 1)) { timeline in
                            ConstructionSiteArt()
                                .frame(width: size, height: size)
                                .overlay(alignment: .bottom) {
                                    Text(timerInterval: min(timeline.date, construction.endsAt)...construction.endsAt, countsDown: true)
                                        .font(.caption2.bold()).monospacedDigit()
                                        .foregroundStyle(Palette.paper)
                                        .padding(.horizontal, 6).padding(.vertical, 3)
                                        .background(Palette.ocean, in: .capsule)
                                        .fixedSize()
                                }
                        }
                    } else if let building {
                        Ellipse()
                            .fill(.black.opacity(0.20))
                            .frame(width: footprintWidth, height: footprintHeight)
                            .offset(y: size * 0.30)
                        BuildingArt(kind: building)
                            .frame(width: size, height: size)
                            .overlay(alignment: .bottom) {
                                TideLevelBadge(level: 1, selected: selected)
                                    .offset(x: size * (plot == 13 ? -0.22 : 0.22), y: size * 0.05)
                                    .accessibilityHidden(true)
                            }
                            .offset(y: -size * 0.13)
                            .accessibilityHidden(true)
                    } else if building == nil && site == nil && canReceiveMovingBuilding {
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

                    }

                    if mode == .townCenter, plot == SettlementLayout.expeditionQuayPlot,
                       building == nil, construction == nil, !canReceiveMovingBuilding {
                        Label(String(localized: "screen.village_board.quay", defaultValue: "Quai"), systemImage: "sailboat.fill")
                            .font(.caption.bold()).foregroundStyle(Palette.paper)
                            .padding(.horizontal, 10)
                            .frame(minHeight: 38)
                            .background(Palette.panel, in: .capsule)
                            .overlay { Capsule().strokeBorder(Palette.amber.opacity(0.8), lineWidth: 1.5) }
                    }

                    if session.moveSourcePlot == plot || canReceiveMovingBuilding {
                        if site == nil && (building == nil || session.moveSourcePlot == plot || canReceiveMovingBuilding) {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    canReceiveMovingBuilding ? .green : Palette.amber,
                                    lineWidth: selected || session.moveSourcePlot == plot ? 3 : 2
                                )
                                .frame(width: size * 0.68, height: size * 0.30)
                                .shadow(color: (canReceiveMovingBuilding ? Color.green : Palette.amber).opacity(0.7), radius: 8)
                                .offset(y: size * (building == nil ? 0.14 : 0.22))
                        }
                    }
                }
                .frame(width: size, height: size)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.55).onEnded { _ in
            beginMovingBuilding(at: plot)
        })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(plotAccessibilityLabel(for: plot))
        .accessibilityIdentifier("plot.\(mode.rawValue).\(plot)")
        .accessibilityValue(selected ? String(localized: "screen.village_board.selected", defaultValue: "Sélectionné") : "")
        .accessibilityHint(plotAccessibilityHint(for: plot))
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityAction { selectPlot(plot) }
        .accessibilityActions {
            if canMoveBuilding(at: plot) {
                Button(String(localized: "screen.village_board.move_building", defaultValue: "Déplacer le bâtiment")) {
                    beginMovingBuilding(at: plot)
                }
            }
        }
    }

    private func accessibilityBorderColor(selected: Bool, canReceive: Bool) -> Color {
        if canReceive { return Color.green }
        if selected { return Palette.amber }
        return Color.clear
    }

    private func selectPlot(_ plot: Int) {
        let isMoving = session.moveSourcePlot != nil || session.pendingBuilding != nil
        session.selectPlot(plot)
        selectedPlot = session.plot
        if !isMoving { onPlotSelected() }
    }

    private func canMoveBuilding(at plot: Int) -> Bool {
        guard mode == .townCenter, let building = session.state.buildings[plot] else { return false }
        return building != .hall && building != .expeditionQuay && session.state.construction?.plot != plot
    }

    private func beginMovingBuilding(at plot: Int) {
        guard canMoveBuilding(at: plot) else { return }
        session.selectPlot(plot)
        selectedPlot = session.plot
        session.beginMovingSelectedBuilding()
    }

    private func plotAccessibilityLabel(for plot: Int) -> String {
        if mode == .resourceFields, let site = ResourceSiteKind.at(plot) {
            return String(localized: "screen.village_board.site_value_value_level_value", defaultValue: "Zone \(String(mode.slotNumber(for: plot) ?? 0)), \(String(site.name)), niveau \(String(session.state.resourceLevel(at: plot)))")
        }
        if let construction = session.state.construction, construction.plot == plot {
            return String(localized: "screen.village_board.construction_of_value_value_percent_complete", defaultValue: "Chantier de \(String(construction.kind.name)), \(String(Int(construction.progress(at: .now) * 100))) pour cent terminé")
        }
        let building = session.state.buildings[plot]
        let terrain = VillageState.ground(at: plot)
        let isUnavailable = building == nil && !BuildingKind.constructible(in: mode).contains { $0.suits(terrain) }
        return String(localized: "screen.village_board.plot_value_value_value", defaultValue: "Emplacement \(String(mode.slotNumber(for: plot) ?? 0)), \(String(building?.name ?? terrain.name))\(String(isUnavailable ? String(localized: "screen.village_board.unavailable", defaultValue: ", indisponible") : ""))")
    }

    private func plotAccessibilityHint(for plot: Int) -> String {
        let site = mode == .resourceFields ? ResourceSiteKind.at(plot) : nil
        return session.moveSourcePlot == nil
            ? (site == nil ? String(localized: "screen.village_board.view_details_or_build_on_this_plot", defaultValue: "Afficher les détails ou construire sur cet emplacement") : String(localized: "screen.village_board.view_production_and_upgrade_this_site", defaultValue: "Afficher la production et améliorer cette zone"))
            : String(localized: "screen.village_board.move_the_selected_building_to_this_plot_if_compatible", defaultValue: "Déplacer le bâtiment sélectionné vers cette case si elle est compatible")
    }

    private func position(for plot: Int, in size: CGSize) -> CGPoint {
        let point = mode.mapPoint(for: plot)
        return CGPoint(x: size.width * point.x, y: size.height * point.y)
    }

}
