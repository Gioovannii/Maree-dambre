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

    var body: some View {
        NavigationStack {
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
            .background(Palette.ocean.ignoresSafeArea())
            .navigationTitle(mode == .resourceFields ? String(localized: "screen.plot_detail.upgrade", defaultValue: "Amélioration") : session.state.construction?.plot == session.plot ? (session.state.construction?.kind.name ?? String(localized: "screen.plot_detail.your_plot", defaultValue: "Votre parcelle")) : (session.state.buildings[session.plot]?.name ?? String(localized: "screen.plot_detail.your_plot", defaultValue: "Votre parcelle")))
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
