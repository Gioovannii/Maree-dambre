import SwiftUI
import SpriteKit

struct WorldCanvas: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var scene = ArchipelagoScene(size: CGSize(width: 390, height: 500))

    var body: some View {
        VStack(spacing: 12) {
            SpriteView(scene: scene, isPaused: scenePhase == .background, preferredFramesPerSecond: 30)
                .frame(height: 500)
                .overlay(alignment: .topLeading) {
                    Label("MER DES ÉCHOS", systemImage: "location.north.fill")
                        .font(.caption.bold()).tracking(2)
                        .padding(12).background(Palette.ocean.opacity(0.85), in: .capsule)
                        .padding(12).allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 24))
                .contentShape(.rect)
                .gesture(DragGesture(minimumDistance: 8)
                    .onChanged { scene.pan($0.translation, ended: false) }
                    .onEnded { scene.pan($0.translation, ended: true) })
                .simultaneousGesture(MagnifyGesture()
                    .onChanged { scene.zoom($0.magnification, ended: false) }
                    .onEnded { scene.zoom($0.magnification) })
                .simultaneousGesture(SpatialTapGesture().onEnded { session.selectedTile = scene.tile(at: $0.location) })
                .accessibilityLabel("Archipel et villages voisins")
                .accessibilityHint("Choisissez une destination avec les boutons sous la carte.")
            HStack {
                Button("Dézoomer", systemImage: "minus.magnifyingglass") { scene.zoom(1 / 1.3) }.labelStyle(.iconOnly)
                Button("Zoomer", systemImage: "plus.magnifyingglass") { scene.zoom(1.3) }.labelStyle(.iconOnly)
                Spacer()
                Button("Vue d’ensemble", systemImage: "viewfinder") { scene.overview() }
            }
            .buttonStyle(.bordered).controlSize(.large)
            Text("Glissez pour explorer · Pincez pour zoomer · Touchez un village")
                .font(.caption).foregroundStyle(Palette.muted)
            ScrollView(.horizontal) {
                HStack {
                    Button("Mon village", systemImage: "house.fill") { session.selectedTile = .home; scene.select(.home) }
                    ForEach(session.state.bots) { bot in
                        Button(bot.name) { session.selectedTile = bot.capital; scene.select(bot.capital) }
                            .tint(Self.factionColor(bot.id))
                    }
                }
                .buttonStyle(.bordered)
            }
            .scrollIndicators(.hidden)
            DisclosureGroup("Choisir une position") {
                Stepper("Colonne : \(session.selectedTile.x)", onIncrement: { move(dx: 1, dy: 0) }, onDecrement: { move(dx: -1, dy: 0) })
                Stepper("Ligne : \(session.selectedTile.y)", onIncrement: { move(dx: 0, dy: 1) }, onDecrement: { move(dx: 0, dy: -1) })
            }
            HStack(spacing: 14) {
                Label("Forêts", systemImage: "tree.fill").foregroundStyle(.green)
                Label("Ambre", systemImage: "sparkles").foregroundStyle(Palette.amber)
                Label("Territoires", systemImage: "flag.fill").foregroundStyle(.cyan)
            }
            .font(.caption)
        }
        .tint(Palette.amber)
        .onAppear {
            scene.reducedMotion = reduceMotion
            scene.configure(world: session.world, bots: session.state.bots, selected: session.selectedTile)
            scene.overview()
        }
        .onChange(of: session.selectedTile) { scene.select(session.selectedTile) }
        .onChange(of: session.state.bots) { scene.configure(world: session.world, bots: session.state.bots, selected: session.selectedTile) }
        .onChange(of: reduceMotion) { scene.reducedMotion = reduceMotion }
    }

    private func move(dx: Int, dy: Int) {
        session.selectedTile = TileCoordinate(x: min(199, max(0, session.selectedTile.x + dx)), y: min(199, max(0, session.selectedTile.y + dy)))
    }

    static func factionColor(_ id: Int) -> Color {
        switch id {
        case 0: .orange
        case 1: .cyan
        default: .purple
        }
    }
}
