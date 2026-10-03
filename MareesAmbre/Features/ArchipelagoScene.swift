import SpriteKit
import UIKit

@MainActor
final class ArchipelagoScene: SKScene {
    private let viewpoint = SKCameraNode()
    private let markers = SKNode()
    private let selection = SKShapeNode(circleOfRadius: 38)
    private let route = SKShapeNode()
    private var currentSeed: Int?
    private var terrainTask: Task<Void, Never>?
    private let loading = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private var dragStart: CGPoint?
    private var zoomStart: CGFloat?
    private var locations: [TileCoordinate] = []
    private let unit: CGFloat = 24
    var reducedMotion = false {
        didSet { childNode(withName: "sea").flatMap { $0 as? SKSpriteNode }?.shader?.uniformNamed("u_motion")?.floatValue = reducedMotion ? 0 : 1 }
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
            vec3 deep = vec3(0.025, 0.19, 0.29);
            vec3 water = deep + vec3(0.02, 0.08, 0.09) * (wave * 0.5 + 0.5);
            gl_FragColor = vec4(water + shimmer * vec3(0.07, 0.12, 0.12), 1.0);
        }
        """)
        sea.shader?.addUniform(SKUniform(name: "u_motion", float: 1))
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
        selection.strokeColor = .systemYellow
        selection.lineWidth = 3
        selection.fillColor = .clear
        selection.zPosition = 8
        addChild(selection)
        route.strokeColor = UIColor.systemYellow.withAlphaComponent(0.65)
        route.lineWidth = 3
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
        addVillage(tile: .home, name: String(localized: "screen.archipelago_scene.amber_harbor", defaultValue: "PORT D’AMBRE"), asset: "MaisonVeilleurs", color: .systemYellow)
        for bot in bots {
            let color = [UIColor.systemOrange, .systemCyan, .systemPurple][bot.id % 3]
            for tile in bot.territory {
                let patch = SKShapeNode(circleOfRadius: 13)
                patch.position = point(tile)
                patch.fillColor = color.withAlphaComponent(0.22)
                patch.strokeColor = .clear
                markers.addChild(patch)
            }
            addVillage(tile: bot.capital, name: bot.displayName.uppercased(), asset: ["CourArmes", "MaisonSavoirs", "Ferme"][bot.id % 3], color: color)
        }
        select(selected, focus: false)
    }

    private func addVillage(tile: TileCoordinate, name: String, asset: String, color: UIColor) {
        let node = SKNode()
        node.name = "village"
        node.position = point(tile)
        let halo = SKShapeNode(ellipseOf: CGSize(width: 95, height: 45))
        halo.fillColor = color.withAlphaComponent(0.2)
        halo.strokeColor = color.withAlphaComponent(0.8)
        node.addChild(halo)
        let building = SKSpriteNode(imageNamed: asset)
        building.size = CGSize(width: 100, height: 100)
        building.position.y = 30
        node.addChild(building)
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = name
        label.fontSize = 22
        label.fontColor = .white
        label.position.y = -28
        let plate = SKShapeNode(rectOf: CGSize(width: max(130, label.frame.width + 22), height: 30), cornerRadius: 12)
        plate.position.y = -22
        plate.fillColor = UIColor(red: 0.03, green: 0.12, blue: 0.17, alpha: 0.95)
        plate.strokeColor = color.withAlphaComponent(0.6)
        node.addChild(plate)
        node.addChild(label)
        node.setScale(max(1, viewpoint.xScale / 2.4))
        markers.addChild(node)
    }

    func point(_ tile: TileCoordinate) -> CGPoint {
        CGPoint(x: (CGFloat(tile.x) + 0.5) * unit, y: -(CGFloat(tile.y) + 0.5) * unit)
    }

    func select(_ tile: TileCoordinate, focus: Bool = true) {
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
        for node in markers.children where node.name == "village" {
            node.setScale(max(1, viewpoint.xScale / 2.4))
        }
        if ended { zoomStart = nil }
    }

    func overview() {
        viewpoint.removeAllActions()
        viewpoint.position = CGPoint(x: 105 * unit, y: -103 * unit)
        viewpoint.setScale(max(1.5, 850 / max(size.width, 1)))
    }
}
