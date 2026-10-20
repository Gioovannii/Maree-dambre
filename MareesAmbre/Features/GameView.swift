import SwiftUI
import TipKit

struct GameView: View {
    @State private var showsMailbox = ProcessInfo.processInfo.arguments.contains("--snapshot-mailbox") || ProcessInfo.processInfo.arguments.contains("--snapshot-mail-detail")
    @State private var showsShipment = ProcessInfo.processInfo.arguments.contains("--snapshot-shipment")
    @State private var showsExpansion = ProcessInfo.processInfo.arguments.contains("--snapshot-expansion") && !ProcessInfo.processInfo.arguments.contains("--snapshot-colony") && !ProcessInfo.processInfo.arguments.contains("--snapshot-shipment")
    @State private var showsGuide = ProcessInfo.processInfo.arguments.contains("--snapshot-guide")
    @Environment(VillageSession.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showsWorld = ProcessInfo.processInfo.arguments.contains("--snapshot-world") && !ProcessInfo.processInfo.arguments.contains("--snapshot-raid")
    @State private var showsMissions = ProcessInfo.processInfo.arguments.contains("--snapshot-protection") || ProcessInfo.processInfo.arguments.contains("--snapshot-missions") || ProcessInfo.processInfo.arguments.contains("--snapshot-raid") || ProcessInfo.processInfo.arguments.contains("--snapshot-raid-report")
    @State private var showsVillageDetails = ProcessInfo.processInfo.arguments.contains("--snapshot-upgrade") || VillageSession.snapshotBuilding != nil
    @State private var villageMap: VillageMapMode = ProcessInfo.processInfo.arguments.contains("--snapshot-center") || VillageSession.snapshotBuilding != nil
        ? .townCenter : .resourceFields
    @State private var selectedResourcePlot = VillageMapMode.resourceFields.initialPlot
    @State private var selectedTownPlot = VillageSession.snapshotTownPlot

    var body: some View {
        GeometryReader { viewport in
            if session.state.people == nil {
                PrologueView(saveRecoveryMessage: session.saveRecoveryMessage, onChoose: session.choosePeople)
            } else if typeSize.isAccessibilitySize {
                accessibilityScreen
            } else if showsMailbox {
                mailboxScreen
            } else if viewport.size.width >= 700 && viewport.size.height >= 600 {
                tabletScreen
            } else if showsWorld {
                worldScreen
            } else if showsMissions {
                missionsScreen
            } else {
                villageScreen
            }
        }
        .sheet(isPresented: $showsShipment) { ShipmentView() }
        .sheet(isPresented: $showsExpansion) { ExpansionView() }
        .preferredColorScheme(.dark)
        .overlay(alignment: .bottomTrailing) {
            if let people = session.state.people, !showsVillageDetails, !showsMailbox, session.state.settlementCount < 2 {
                GeometryReader { viewport in
                    VillageCompanionOverlay(people: people, step: VillageGuideStep.next(in: session.state),
                                            maximumHeight: max(160, min(420, viewport.size.height - 160)),
                                            isExpanded: $showsGuide) {
                        showsGuide = false
                        let step = VillageGuideStep.next(in: session.state)
                        if step == .complete {
                            showsMailbox = false
                            showsWorld = true
                            showsMissions = false
                            showsExpansion = true
                        }
                        switch step.destination {
                        case "resources": selectVillageMap(.resourceFields)
                        case "town": if step != .complete { selectVillageMap(.townCenter) }
                        default: showMissions()
                        }
                        session.guidedStep = step
                        if step != .raid && step != .complete {
                            let mode: VillageMapMode = step == .fields ? .resourceFields : .townCenter
                            let kind: BuildingKind = (step == .academy || step == .research) ? .academy : .warCourt
                            let target: Int? = step == .fields
                                ? mode.slots.first(where: { session.state.canDevelopResource(at: $0) }) ?? mode.slots.first
                                : session.state.buildings.first(where: { $0.value == kind })?.key
                                    ?? mode.slots.first(where: { session.state.canBuild(kind, at: $0) })
                                    ?? mode.slots.first(where: { session.state.buildings[$0] == nil && VillageState.canPlace(kind, at: $0) })
                            if let target {
                                session.plot = target
                                if mode == .resourceFields { selectedResourcePlot = target }
                                else { selectedTownPlot = target }
                                showsVillageDetails = typeSize.isAccessibilitySize || viewport.size.width < 700 || viewport.size.height < 600
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.horizontal, 12)
                    .padding(.bottom, typeSize.isAccessibilitySize ? 12 : 88)
                }
            }
        }
    }

    private var accessibilityScreen: some View {
        ScrollView {
            VStack(spacing: 16) {
                topControls
                navigation
                constructionStatus
                if showsWorld {
                    WorldPanel(onShowVillage: { selectVillageMap(.resourceFields) }, onShowMissions: showMissions, mapHeight: 320)
                } else if showsMissions {
                    MissionsPanel()
                } else if showsMailbox {
                    MailboxPanel()
                } else {
                    VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding,
                                 onPlotSelected: { showsVillageDetails = true },
                                 onTownSelected: { selectVillageMap(.townCenter) })
                        .id(villageMap)
                }
            }
            .padding(12)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.ocean.ignoresSafeArea())
        .foregroundStyle(Palette.paper)
        .onAppear {
            session.plot = villageMap == .resourceFields ? selectedResourcePlot : selectedTownPlot
        }
        .fullScreenCover(isPresented: $showsVillageDetails) {
            PlotDetailScreen(mode: villageMap)
        }
    }

    private var tabletScreen: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Group {
                    if showsWorld {
                        ScrollView {
                            WorldPanel(onShowVillage: { selectVillageMap(.resourceFields) }, onShowMissions: showMissions, mapHeight: 500, showsSelection: false)
                                .padding(20)
                        }
                    } else if showsMissions {
                        ScrollView {
                            MissionsPanel()
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
                                WorldSelectionPanel(onShowVillage: { selectVillageMap(.resourceFields) }, onShowMissions: showMissions)
                                WorldClockStatus()
                            }
                            .padding(20)
                        }
                    } else if showsMissions {
                        ScrollView {
                            WorldClockStatus()
                                .padding(20)
                        }
                    } else {
                        PlotDetailScreen(mode: villageMap, isEmbedded: true)
                            .id(villageMap)
                    }
                }
                .padding(.top, 12)
                .frame(width: tabletSidebarWidth(in: geometry.size))
                .background(Palette.ocean)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Palette.ocean.ignoresSafeArea())
            .foregroundStyle(Palette.paper)
            .onAppear {
                session.plot = villageMap == .resourceFields ? selectedResourcePlot : selectedTownPlot
            }
            }
    }

    private func tabletSidebarWidth(in size: CGSize) -> CGFloat {
        let preferred: CGFloat = size.width > size.height ? 400 : 350
        return min(preferred, max(320, size.width * 0.42))
    }

    private var villageScreen: some View {
        GeometryReader { geometry in
            ZStack {
                Palette.ocean.ignoresSafeArea()
                VillageBoard(mode: villageMap, selectedPlot: selectedPlotBinding,
                             onPlotSelected: { showsVillageDetails = true },
                             onTownSelected: { selectVillageMap(.townCenter) },
                             showsTownShortcut: false)
                .id(villageMap)
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    topControls
                        .frame(maxWidth: 560)
                    Spacer(minLength: 4)
                    constructionStatus
                        .frame(maxWidth: 560)
                    if villageMap == .resourceFields {
                        TownShortcutButton { selectVillageMap(.townCenter) }
                    }
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
                            Text(String(localized: "progression.construction.status", defaultValue: "CHANTIER · \(String(job.kind.name.uppercased())) · N\(String(job.level))"))
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
                    WorldPanel(onShowVillage: { selectVillageMap(.resourceFields) }, onShowMissions: showMissions, mapHeight: min(480, max(280, geometry.size.height - 350)))
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

    private var missionsScreen: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                topControls
                    .frame(maxWidth: 560)
                ScrollView {
                    MissionsPanel()
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
            if let summary = session.absenceSummary {
                AbsenceSummaryBanner(summary: summary) {
                    showsVillageDetails = false
                    showsWorld = false
                    showsMissions = false
                    showsMailbox = true
                }
            }
            ResourcesView(
                resources: session.state.resources,
                hourlyProduction: session.state.production,
                storageCapacity: session.state.storageCapacity
            )
            HStack(spacing: 8) {
                if !showsMailbox { header } else { Spacer(minLength: 0) }
                HeroAccessButton()
            }
            if session.state.settlementCount > 1 {
                Menu {
                    ForEach(session.state.ownedLocations, id: \.self) { location in
                        Button {
                            session.switchSettlement(to: location)
                        } label: {
                            let name = session.settlementName(at: location)
                            Label(name + " · \(location.x), \(location.y)", systemImage: location == session.state.location ? "checkmark.circle.fill" : "house.fill")
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Label(session.state.settlementName, systemImage: session.state.isRefuge ? "shield.fill" : "building.2.crop.circle.fill")
                        Image(systemName: "chevron.down").font(.caption.bold())
                    }
                    .font(.subheadline.bold()).padding(.horizontal, 12).frame(minHeight: 44)
                    .background(Palette.panel, in: .capsule)
                }
                .tint(Palette.amber)
                .accessibilityIdentifier("settlement.switch")
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        if showsWorld || showsMissions || showsMailbox {
            HStack {
                Text(showsMailbox ? String(localized: "mail.title", defaultValue: "Messagerie") : showsWorld ? String(localized: "screen.game.the_archipelago", defaultValue: "L’archipel") : showsMissions ? String(localized: "screen.game.missions", defaultValue: "Missions") : villageMap.title)
                    .font(.headline.bold()).fontDesign(.serif)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 1)
                    .minimumScaleFactor(typeSize.isAccessibilitySize ? 1 : 0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Palette.panel, in: .capsule)
                    .contentTransition(.opacity)
                Spacer(minLength: 0)
            }
            .foregroundStyle(Palette.paper)
        } else {
            Text(villageMap == .townCenter ? villageMap.title : String(localized: "screen.game.amber_estate", defaultValue: "Domaine d’Ambre"))
                .font(.headline).fontDesign(.serif)
                .foregroundStyle(Palette.paper)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Palette.ocean, in: .capsule)
                .frame(maxWidth: .infinity)

        }
    }

    private var currentSection: GameSection {
        if showsMailbox { return .mailbox }
        if showsWorld { return .world }
        if showsMissions { return .missions }
        return villageMap == .resourceFields ? .resources : .town
    }

    private var navigation: some View {
        GameNavigationBar(selected: currentSection, unreadCount: session.state.unreadMailCount) { section in
            switch section {
            case .resources: selectVillageMap(.resourceFields)
            case .town: selectVillageMap(.townCenter)
            case .missions: showMissions()
            case .world:
                showsWorld = true
                showsMissions = false
                showsMailbox = false
            case .mailbox:
                showsWorld = false
                showsMissions = false
                showsMailbox = true
            }
        }
    }

    private var mailboxScreen: some View {
        VStack(spacing: 10) {
            topControls.frame(maxWidth: 720)
            ScrollView {
                MailboxPanel().padding(.vertical, 12)
                    .frame(maxWidth: 720).frame(maxWidth: .infinity)
            }
            navigation.frame(maxWidth: 720)
        }
        .padding(.horizontal, 12).padding(.top, 7)
        .background(Palette.ocean.ignoresSafeArea())
    }

    private func selectVillageMap(_ mode: VillageMapMode) {
        showsMailbox = false
        showsWorld = false
        showsMissions = false
        if session.moveSourcePlot != nil || session.pendingBuilding != nil { session.cancelPlacement() }
        guard villageMap != mode else { return }
        villageMap = mode
        session.plot = mode == .resourceFields ? selectedResourcePlot : selectedTownPlot
    }

    private func showMissions() {
        showsMailbox = false
        showsWorld = false
        showsMissions = true
    }

    private var selectedPlotBinding: Binding<Int> {
        switch villageMap {
        case .resourceFields: $selectedResourcePlot
        case .townCenter: $selectedTownPlot
        }
    }

}

#Preview { GameView().environment(VillageSession()) }
