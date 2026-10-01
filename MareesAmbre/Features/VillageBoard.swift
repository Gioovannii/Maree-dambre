import SwiftUI

struct VillageBoard: View {
    let mode: VillageMapMode
    @Binding var selectedPlot: Int
    let onPlotSelected: () -> Void
    let onTownSelected: () -> Void
    var preservesMapProportions = false
    @Environment(VillageSession.self) private var session

    var body: some View {
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
                    Image(mode.assetName)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: mapSize.width, height: mapSize.height)
                        .clipped()
                        .accessibilityHidden(true)

                    ForEach(visibleSlots, id: \.self) { plot in
                        plotButton(plot, mapWidth: mapSize.width)
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
                        .position(x: mapSize.width * 0.50, y: mapSize.height * 0.79)
                        .zIndex(100)
                        .accessibilityHint("Ouvrir le port et les bâtiments du Centre-ville")
                    }
                }
                .frame(width: mapSize.width, height: mapSize.height)
            }
            .frame(width: viewSize.width, height: viewSize.height)
            .clipped()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Carte entière du district : \(mode.title).")
    }

    private var visibleSlots: [Int] {
        mode.slots.filter {
            mode.defaultVisibleSlots.contains($0) || session.state.buildings[$0] != nil
                || session.state.construction?.plot == $0
        }
    }

    private func plotButton(_ plot: Int, mapWidth: CGFloat) -> some View {
        let building = session.state.buildings[plot]
        let construction = session.state.construction?.plot == plot ? session.state.construction : nil
        let constructionProgress = construction?.progress(at: Date()) ?? 0
        let selected = session.plot == plot
        let terrain = VillageState.ground(at: plot)
        let site = mode == .resourceFields ? ResourceSiteKind.at(plot) : nil
        let siteLevel = session.state.resourceLevel(at: plot)
        let isUnavailable = mode == .townCenter && building == nil
            && !BuildingKind.constructible(in: mode).contains { $0.suits(terrain) }
        // Equal, compact footprints keep the Centre readable and leave room
        // for several buildings without making one lot dominate the map.
        let size = min(76, max(52, mapWidth * 0.145))
        let footprintWidth = size * 0.82
        let footprintHeight = size * 0.34
        let canReceiveMovingBuilding = (session.pendingBuilding.map { session.state.canBuild($0, at: plot) } ?? false) || (session.moveSourcePlot.map {
            building == nil && session.state.canMoveBuilding(from: $0, to: plot)
        } ?? false)
        let plotAccessibilityLabel: String
        if let site {
            plotAccessibilityLabel = "Zone \(mode.slotNumber(for: plot) ?? 0), \(site.name), niveau \(siteLevel)"
        } else if let construction {
            plotAccessibilityLabel = "Chantier de \(construction.kind.name), \(Int(constructionProgress * 100)) pour cent terminé"
        } else {
            plotAccessibilityLabel = "Emplacement \(mode.slotNumber(for: plot) ?? 0), \(building?.name ?? terrain.name)\(isUnavailable ? ", indisponible" : "")"
        }

        return Button {
            let isMoving = session.moveSourcePlot != nil || session.pendingBuilding != nil
            session.selectPlot(plot)
            selectedPlot = session.plot
            if !isMoving { onPlotSelected() }
        } label: {
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
                if let site {
                    Image(site.imageAssetName)
                        .resizable().scaledToFit()
                        .frame(width: size, height: size)
                        .accessibilityHidden(true)

                    TideLevelBadge(level: siteLevel, symbol: site.symbol)
                        .offset(y: size * 0.34)
                        .overlay(alignment: .bottom) {
                            if let job = session.state.resourceUpgrade, job.plot == plot {
                                Text(timerInterval: min(Date.now, job.endsAt)...job.endsAt, countsDown: true)
                                    .font(.caption2.bold()).monospacedDigit().fixedSize()
                                    .padding(4)
                                    .background(Palette.ocean, in: .capsule)
                                    .offset(y: 20)
                            }
                        }
                        .overlay {
                            if selected {
                                Capsule()
                                    .strokeBorder(Palette.amber, lineWidth: 2.5)
                            }
                        }
                        .shadow(color: selected ? Palette.amber.opacity(0.6) : .clear, radius: 6)
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
                            TideLevelBadge(level: 1)
                                .overlay {
                                    if selected {
                                        Capsule().strokeBorder(Palette.amber, lineWidth: 2.5)
                                    }
                                }
                                .shadow(color: selected ? Palette.amber.opacity(0.55) : .clear, radius: 5)
                                .offset(y: -size * 0.01)
                                .accessibilityHidden(true)
                        }
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
        .buttonStyle(.plain)
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.55).onEnded { _ in
            guard mode == .townCenter, building != nil, construction == nil else { return }
            session.selectPlot(plot)
            session.beginMovingSelectedBuilding()
        })
        .accessibilityLabel(plotAccessibilityLabel)
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

}
