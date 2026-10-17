import SpriteKit
import UIKit

@MainActor
final class ArchipelagoScene: SKScene {
    private let viewpoint = SKCameraNode()
    private let markers = SKNode()
    private let selection = SKShapeNode(ellipseOf: CGSize(width: 48, height: 30))
    private let route = SKShapeNode()
    private var currentSeed: Int?
    private var terrainTask: Task<Void, Never>?
    private let loading = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private var dragStart: CGPoint?
    private var zoomStart: CGFloat?
    private var locations: [TileCoordinate] = []
    private var selectedTile = TileCoordinate.home
    private let unit: CGFloat = 24
    private var seaMotion: Float {
        reducedMotion || ProcessInfo.processInfo.arguments.contains("--ui-snapshot") ? 0 : 1
    }
    var reducedMotion = false {
        didSet { childNode(withName: "sea").flatMap { $0 as? SKSpriteNode }?.shader?.uniformNamed("u_motion")?.floatValue = seaMotion }
    }

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = UIColor(red: 0.025, green: 0.16, blue: 0.24, alpha: 1)
        let sea = SKSpriteNode(color: .white, size: CGSize(width: 12000, height: 12000))
        sea.position = CGPoint(x: 2400, y: -2400)
        sea.name = "sea"
        sea.zPosition = -1
        sea.shader = SKShader(source: """
        void main() {
            vec2 p = v_tex_coord * 120.0;
            float wave = sin(p.x * 2.4 + sin(p.y * 1.8) + u_time * u_motion * 0.3);
            float shimmer = pow(max(0.0, wave * sin(p.y * 3.0 - u_time * u_motion * 0.2)), 12.0);
            float depth = sin(p.x * 0.17 + p.y * 0.21) * 0.5 + 0.5;
            vec3 deep = mix(vec3(0.035, 0.29, 0.40), vec3(0.045, 0.43, 0.52), depth);
            vec3 water = deep + vec3(0.015, 0.045, 0.055) * (wave * 0.5 + 0.5);
            gl_FragColor = vec4(water + shimmer * vec3(0.10, 0.20, 0.19), 1.0);
        }
        """)
        sea.shader?.addUniform(SKUniform(name: "u_motion", float: seaMotion))
        addChild(sea)
        addChild(viewpoint)
        loading.text = String(localized: "screen.archipelago_scene.preparing_the_archipelago", defaultValue: "Préparation de l’archipel…")
        loading.fontSize = 15
        loading.fontColor = .white
        loading.zPosition = 100
        loading.isHidden = true
        viewpoint.addChild(loading)
        camera = viewpoint
        viewpoint.setScale(2.4)
        viewpoint.position = point(.home)
        markers.zPosition = 5
        addChild(markers)
        selection.strokeColor = WorldMapStyle.amber
        selection.lineWidth = 1.6
        selection.fillColor = .clear
        selection.zPosition = 4.5
        addChild(selection)
        route.strokeColor = WorldMapStyle.amber.withAlphaComponent(0.75)
        route.lineWidth = 1.8
        route.zPosition = 4
        addChild(route)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(world: WorldMap, bots: [BotFaction], selected: TileCoordinate) {
        if currentSeed != world.seed {
            currentSeed = world.seed
            loading.isHidden = false
            markers.isHidden = true
            selection.isHidden = true
            route.isHidden = true
            terrainTask?.cancel()
            terrainTask = Task { [weak self] in
                let texture = await WorldTerrainTexture.make(world)
                guard !Task.isCancelled, let self, self.currentSeed == world.seed else { return }
                self.childNode(withName: "terrain")?.removeFromParent()
                let terrain = SKSpriteNode(texture: texture)
                terrain.name = "terrain"
                terrain.size = CGSize(width: 4800, height: 4800)
                terrain.position = CGPoint(x: 2400, y: -2400)
                self.addChild(terrain)
                self.loading.isHidden = true
                self.markers.isHidden = false
                self.selection.isHidden = false
                self.route.isHidden = false
            }
        }
        markers.removeAllChildren()
        locations = [.home] + bots.map(\.capital)
        addVillage(tile: .home, name: String(localized: "screen.world.amber_harbor", defaultValue: "Port d’Ambre"), asset: "MaisonVeilleurs", color: WorldMapStyle.amber)
        for bot in bots {
            let color = WorldMapStyle.factionColor(bot.id)
            for tile in bot.territory {
                let patch = SKShapeNode(circleOfRadius: 13)
                patch.position = point(tile)
                patch.fillColor = color.withAlphaComponent(0.10)
                patch.strokeColor = color.withAlphaComponent(0.4)
                patch.lineWidth = 0.8
                markers.addChild(patch)
            }
            addVillage(tile: bot.capital, name: WorldNeighbor.name(for: bot, seed: world.seed), asset: ["CourArmes", "MaisonSavoirs", "Ferme"][bot.id % 3], color: color)
        }
        select(selected, focus: false)
    }

    private func addVillage(tile: TileCoordinate, name: String, asset: String, color: UIColor) {
        let node = WorldVillageMarker.make(name: name, asset: asset, color: color, isHome: tile == .home)
        node.position = point(tile)
        markers.addChild(node)
    }

    func point(_ tile: TileCoordinate) -> CGPoint {
        CGPoint(x: (CGFloat(tile.x) + 0.5) * unit, y: -(CGFloat(tile.y) + 0.5) * unit)
    }

    func select(_ tile: TileCoordinate, focus: Bool = true) {
        selectedTile = tile
        updateVillageMarkers()
        selection.position = point(tile)
        let path = CGMutablePath()
        if tile != .home {
            let start = point(.home), end = point(tile)
            path.move(to: start)
            path.addQuadCurve(to: end, control: CGPoint(x: (start.x + end.x) / 2 + 50, y: (start.y + end.y) / 2 + 40))
        }
        route.path = path.copy(dashingWithPhase: 0, lengths: [9, 10])
        if focus {
            viewpoint.removeAllActions()
            if reducedMotion { viewpoint.position = point(tile) }
            else { viewpoint.run(.move(to: point(tile), duration: 0.35)) }
        }
    }

    func tile(at location: CGPoint) -> TileCoordinate {
        let p = convertPoint(fromView: location)
        if let nearest = locations.min(by: { hypot(point($0).x - p.x, point($0).y - p.y) < hypot(point($1).x - p.x, point($1).y - p.y) }),
           hypot(point(nearest).x - p.x, point(nearest).y - p.y) < max(50, 28 * viewpoint.xScale) { return nearest }
        return TileCoordinate(x: min(199, max(0, Int(floor(p.x / unit)))), y: min(199, max(0, Int(floor(-p.y / unit)))))
    }

    func pan(_ translation: CGSize, ended: Bool) {
        viewpoint.removeAllActions()
        if dragStart == nil { dragStart = viewpoint.position }
        if let start = dragStart {
            viewpoint.position = CGPoint(x: min(4800, max(0, start.x - translation.width * viewpoint.xScale)), y: min(0, max(-4800, start.y + translation.height * viewpoint.yScale)))
        }
        if ended { dragStart = nil }
    }

    func zoom(_ factor: CGFloat, ended: Bool = true) {
        if zoomStart == nil { zoomStart = viewpoint.xScale }
        viewpoint.setScale(min(8, max(0.8, (zoomStart ?? 2.4) / factor)))
        updateVillageMarkers()
        if ended { zoomStart = nil }
    }

    func overview() {
        viewpoint.removeAllActions()
        let points = locations.map(point)
        guard let minX = points.map(\.x).min(), let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(), let maxY = points.map(\.y).max() else { return }
        viewpoint.position = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
        // Leave room for nameplates at the edges of the regional overview.
        let horizontalScale = (maxX - minX) / max(size.width - 180, 100)
        let verticalScale = (maxY - minY) / max(size.height - 140, 100)
        viewpoint.setScale(min(8, max(1.5, max(horizontalScale, verticalScale))))
        updateVillageMarkers()
    }

    private func updateVillageMarkers() {
        for node in markers.children where node.name == "village" {
            let isSelected = node.position == point(selectedTile)
            // Around 30 screen points at regional zoom; shrink further when
            // zoomed out so villages do not obscure the surrounding territory.
            node.setScale(min(4, max(0.5, viewpoint.xScale * 0.8)))
            let hideName = viewpoint.xScale > 5 && !isSelected
            node.childNode(withName: "name")?.isHidden = hideName
            node.childNode(withName: "namePlate")?.isHidden = hideName
            node.zPosition = isSelected ? 1 : 0
        }
        selection.setScale(viewpoint.xScale * 0.8)
        route.lineWidth = viewpoint.xScale * 1.2
    }
}
