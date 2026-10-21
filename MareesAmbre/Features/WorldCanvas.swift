import SwiftUI
import SpriteKit

struct WorldCanvas: View {
    var mapHeight: CGFloat = 420
    @Environment(VillageSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var scene = ArchipelagoScene(size: CGSize(width: 390, height: 500))

    var body: some View {
        VStack(spacing: 12) {
            WorldExpeditionsPanel()
            SpriteView(scene: scene, isPaused: scenePhase == .background, preferredFramesPerSecond: 30)
                .frame(height: mapHeight)
                .contentShape(.rect)
                .gesture(DragGesture(minimumDistance: 8)
                    .onChanged { scene.pan($0.translation, ended: false) }
                    .onEnded { scene.pan($0.translation, ended: true) })
                .simultaneousGesture(MagnifyGesture()
                    .onChanged { scene.zoom($0.magnification, ended: false) }
                    .onEnded { scene.zoom($0.magnification) })
                .simultaneousGesture(SpatialTapGesture().onEnded { session.selectedTile = scene.tile(at: $0.location) })
                .accessibilityLabel(String(localized: "screen.world_canvas.archipelago_and_neighboring_villages", defaultValue: "Archipel et villages voisins"))
                .accessibilityHint(String(localized: "screen.world_canvas.choose_a_destination_using_the_buttons_below_the_map", defaultValue: "Choisissez une destination avec les boutons sous la carte."))
                .overlay(alignment: .topLeading) {
                    Label(String(localized: "screen.world_canvas.sea_of_echoes", defaultValue: "MER DES ÉCHOS"), systemImage: "location.north.fill")
                        .font(.caption2.bold()).tracking(1.5)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .foregroundStyle(Palette.paper)
                        .padding(12).background(Palette.ocean.opacity(0.9), in: .capsule)
                        .padding(12).allowsHitTesting(false)
                        .padding(.trailing, 82)
                }
                .overlay(alignment: .topTrailing) {
                    VStack(spacing: 6) {
                        Button(String(localized: "screen.world_canvas.zoom_in", defaultValue: "Zoomer"), systemImage: "plus.magnifyingglass") { scene.zoom(1.3) }
                            .accessibilityIdentifier("world.zoomIn")
                        Button(String(localized: "screen.world_canvas.zoom_out", defaultValue: "Dézoomer"), systemImage: "minus.magnifyingglass") { scene.zoom(1 / 1.3) }
                            .accessibilityIdentifier("world.zoomOut")
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderedProminent)
                    .tint(Palette.ocean.opacity(0.92))
                    .foregroundStyle(Palette.paper)
                    .controlSize(.large)
                    .padding(12)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button(String(localized: "screen.world_canvas.overview", defaultValue: "Vue d’ensemble"), systemImage: "viewfinder") { scene.overview() }
                        .font(.caption.bold())
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.ocean.opacity(0.94))
                        .foregroundStyle(Palette.paper)
                        .controlSize(.large)
                        .accessibilityIdentifier("world.overview")
                        .padding(12)
                }
                .clipShape(.rect(cornerRadius: 24))
                .overlay { RoundedRectangle(cornerRadius: 24).strokeBorder(Palette.amber.opacity(0.35), lineWidth: 1) }
            Text(String(localized: "screen.world_canvas.drag_to_explore_pinch_to_zoom_tap_a_village", defaultValue: "Glissez pour explorer · Pincez pour zoomer · Touchez un village"))
                .font(.caption).foregroundStyle(Palette.muted)
            ScrollView(.horizontal) {
                HStack {
                    Button(String(localized: "screen.world_canvas.my_village", defaultValue: "Mon village"), systemImage: "house.fill") { session.selectedTile = session.state.location; scene.select(session.state.location) }
                        .accessibilityIdentifier("world.home")
                    ForEach(session.state.otherVillages ?? [], id: \.location) { village in
                        Button(village.settlementName, systemImage: "house.fill") { session.selectedTile = village.location; scene.select(village.location) }
                    }
                    ForEach(session.state.bots) { bot in
                        Button(WorldNeighbor.name(for: bot, seed: session.world.seed), systemImage: "flag.fill") { session.selectedTile = bot.capital; scene.select(bot.capital) }
                            .tint(Self.factionColor(bot.id))
                            .accessibilityLabel(String(localized: "world.neighbor.destination", defaultValue: "\(String(WorldNeighbor.name(for: bot, seed: session.world.seed))), \(String(bot.displayName)), voisin simulé"))
                            .accessibilityIdentifier("world.neighbor.\(bot.id)")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .scrollIndicators(.hidden)
            DisclosureGroup(String(localized: "screen.world_canvas.choose_a_position", defaultValue: "Choisir une position")) {
                Stepper(String(localized: "screen.world_canvas.column_value", defaultValue: "Colonne : \(String(session.selectedTile.x))"), onIncrement: { move(dx: 1, dy: 0) }, onDecrement: { move(dx: -1, dy: 0) })
                Stepper(String(localized: "screen.world_canvas.row_value", defaultValue: "Ligne : \(String(session.selectedTile.y))"), onIncrement: { move(dx: 0, dy: 1) }, onDecrement: { move(dx: 0, dy: -1) })
            }
            legendLayout {
                Label(String(localized: "screen.world_canvas.forests", defaultValue: "Forêts"), systemImage: "tree.fill").foregroundStyle(Palette.muted)
                Label(String(localized: "screen.world_canvas.amber", defaultValue: "Ambre"), systemImage: "sparkles").foregroundStyle(Palette.amber)
                Label(String(localized: "screen.world_canvas.territories", defaultValue: "Territoires"), systemImage: "flag.fill").foregroundStyle(Palette.muted)
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(Palette.amber)
        .onAppear {
            scene.reducedMotion = reduceMotion
            scene.configure(world: session.world, bots: session.state.bots, selected: session.selectedTile, homes: session.state.ownedLocations, origin: session.state.location)
            scene.overview()
            scene.setExpeditions(session.state.worldExpeditions)
        }
        .onChange(of: session.selectedTile) { scene.select(session.selectedTile) }
        .onChange(of: session.state.bots) { scene.configure(world: session.world, bots: session.state.bots, selected: session.selectedTile, homes: session.state.ownedLocations, origin: session.state.location) }
        .onChange(of: session.state.ownedLocations) { scene.configure(world: session.world, bots: session.state.bots, selected: session.selectedTile, homes: session.state.ownedLocations, origin: session.state.location) }
        .onChange(of: reduceMotion) { scene.reducedMotion = reduceMotion }
        .onChange(of: session.state.worldExpeditions) { scene.setExpeditions($1) }
    }

    private var legendLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 14))
    }

    private func move(dx: Int, dy: Int) {
        session.selectedTile = TileCoordinate(x: min(199, max(0, session.selectedTile.x + dx)), y: min(199, max(0, session.selectedTile.y + dy)))
    }

    static func factionColor(_ id: Int) -> Color {
        Color(uiColor: WorldMapStyle.factionColor(id))
    }
}
