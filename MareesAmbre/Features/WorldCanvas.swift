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
                    Label(L10n.text("MER DES ÉCHOS", "SEA OF ECHOES"), systemImage: "location.north.fill")
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
                .accessibilityLabel(L10n.text("Archipel et villages voisins", "Archipelago and neighboring villages"))
                .accessibilityHint(L10n.text("Choisissez une destination avec les boutons sous la carte.", "Choose a destination using the buttons below the map."))
            HStack {
                Button(L10n.text("Dézoomer", "Zoom out"), systemImage: "minus.magnifyingglass") { scene.zoom(1 / 1.3) }.labelStyle(.iconOnly)
                Button(L10n.text("Zoomer", "Zoom in"), systemImage: "plus.magnifyingglass") { scene.zoom(1.3) }.labelStyle(.iconOnly)
                Spacer()
                Button(L10n.text("Vue d’ensemble", "Overview"), systemImage: "viewfinder") { scene.overview() }
            }
            .buttonStyle(.bordered).controlSize(.large)
            Text(L10n.text("Glissez pour explorer · Pincez pour zoomer · Touchez un village", "Drag to explore · Pinch to zoom · Tap a village"))
                .font(.caption).foregroundStyle(Palette.muted)
            ScrollView(.horizontal) {
                HStack {
                    Button(L10n.text("Mon village", "My village"), systemImage: "house.fill") { session.selectedTile = .home; scene.select(.home) }
                    ForEach(session.state.bots) { bot in
                        Button(bot.displayName) { session.selectedTile = bot.capital; scene.select(bot.capital) }
                            .tint(Self.factionColor(bot.id))
                    }
                }
                .buttonStyle(.bordered)
            }
            .scrollIndicators(.hidden)
            DisclosureGroup(L10n.text("Choisir une position", "Choose a position")) {
                Stepper(L10n.text("Colonne : \(session.selectedTile.x)", "Column: \(session.selectedTile.x)"), onIncrement: { move(dx: 1, dy: 0) }, onDecrement: { move(dx: -1, dy: 0) })
                Stepper(L10n.text("Ligne : \(session.selectedTile.y)", "Row: \(session.selectedTile.y)"), onIncrement: { move(dx: 0, dy: 1) }, onDecrement: { move(dx: 0, dy: -1) })
            }
            HStack(spacing: 14) {
                Label(L10n.text("Forêts", "Forests"), systemImage: "tree.fill").foregroundStyle(.green)
                Label(L10n.text("Ambre", "Amber"), systemImage: "sparkles").foregroundStyle(Palette.amber)
                Label(L10n.text("Territoires", "Territories"), systemImage: "flag.fill").foregroundStyle(.cyan)
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
