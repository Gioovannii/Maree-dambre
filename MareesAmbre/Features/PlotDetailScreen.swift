import SwiftUI

struct PlotDetailScreen: View {
    let mode: VillageMapMode
    var isEmbedded = false
    @Environment(\.dismiss) private var dismiss
    @Environment(VillageSession.self) private var session

    private var selectedBuilding: BuildingKind? { session.state.buildings[session.plot] }
    private var selectedConstruction: ConstructionJob? {
        guard let job = session.state.construction, job.plot == session.plot else { return nil }
        return job
    }
    private var detailTitle: String {
        if mode == .resourceFields {
            return ResourceSiteKind.at(session.plot)?.name
                ?? String(localized: "screen.plot_detail.your_plot", defaultValue: "Votre parcelle")
        }
        if let selectedConstruction { return selectedConstruction.kind.name }
        if let selectedBuilding { return selectedBuilding.name }
        return String(localized: "screen.plot_detail.your_plot", defaultValue: "Votre parcelle")
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    if !isEmbedded {
                        detailHero
                        .frame(height: 180)
                        .clipped()
                        .overlay(alignment: .bottom) {
                            LinearGradient(colors: [.clear, Palette.ocean], startPoint: .top, endPoint: .bottom)
                        }
                        .accessibilityHidden(true)
                    }
                    if !isEmbedded {
                    ResourcesView(resources: session.state.resources,
                                  hourlyProduction: session.state.production,
                                  storageCapacity: session.state.storageCapacity)
                    }
                    if mode == .resourceFields {
                        ResourceSitePanel()
                    } else {
                        ConstructionPanel(mode: mode)
                    }
                    WorldClockStatus()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(ProcessInfo.processInfo.arguments.contains("--snapshot-actions") ? .bottom : .top)
            .task(id: session.guidedStep) {
                guard let step = session.guidedStep else { return }
                await Task.yield()
                let anchor = step == .academy ? "guide.action.academy" : step == .barracks ? "guide.action.warCourt" : "guide.action"
                proxy.scrollTo(anchor, anchor: .center)
            }
            }
            .background(Palette.ocean.ignoresSafeArea())
            .navigationTitle(detailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isEmbedded { ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "screen.plot_detail.close", defaultValue: "Fermer"), systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                        .tint(Palette.paper)
                }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var detailHero: some View {
        if mode == .townCenter, selectedConstruction != nil {
            ConstructionSiteArt()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Palette.ocean)
        } else if mode == .townCenter, let selectedBuilding {
            BuildingArt(kind: selectedBuilding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Palette.ocean)
        } else {
            Image(mode.assetName)
                .resizable()
                .scaledToFill()
        }
    }
}
