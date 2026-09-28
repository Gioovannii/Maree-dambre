import SwiftUI

struct PlotDetailScreen: View {
    let mode: VillageMapMode
    @Environment(\.dismiss) private var dismiss
    @Environment(VillageSession.self) private var session

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(mode.assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .overlay(alignment: .bottom) {
                            LinearGradient(colors: [.clear, Palette.ocean], startPoint: .top, endPoint: .bottom)
                        }
                        .accessibilityHidden(true)
                    ResourcesView(resources: session.state.resources,
                                  hourlyProduction: session.state.production,
                                  storageCapacity: session.state.storageCapacity)
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
            .navigationTitle(mode == .resourceFields ? "Amélioration" : "Votre parcelle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                        .tint(Palette.paper)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
