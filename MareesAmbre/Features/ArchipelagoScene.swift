import SpriteKit
import UIKit

@MainActor
final class ArchipelagoScene: SKScene {
    private let viewpoint = SKCameraNode()
    private let markers = SKNode()
    private let selection = SKShapeNode(ellipseOf: CGSize(width: 48, height: 30))
    private let route = SKShapeNode()
    private let expeditionLayer = SKNode()
    private var expeditions: [WorldExpedition] = []
    private var lastExpeditionUpdate: TimeInterval = -1
    private var currentSeed: Int?
    private var terrainTask: Task<Void, Never>?
    private let loading = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private var dragStart: CGPoint?
    private var zoomStart: CGFloat?
    private var origin = TileCoordinate.home
    private var homes: [TileCoordinate] = [.home]
    private var locations: [TileCoordinate] = []
    private var selectedTile = TileCoordinate.home
    private let unit: CGFloat = 24
    private var cameraBounds: WorldCameraBounds {
        let extent = CGFloat(WorldMap.side) * unit
        return WorldCameraBounds(viewport: size, worldSize: CGSize(width: extent, height: extent))
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        viewpoint.removeAllActions()
        dragStart = nil
        zoomStart = nil
        constrainCamera()
    }

    private func constrainCamera() {
        viewpoint.setScale(cameraBounds.scale(viewpoint.xScale))
        viewpoint.position = cameraBounds.position(viewpoint.position, scale: viewpoint.xScale)
    }
    private var seaMotion: Float {
        let arguments = ProcessInfo.processInfo.arguments
        let frozenSnapshot = arguments.contains("--ui-snapshot") && !arguments.contains("--snapshot-animate")
        return reducedMotion || frozenSnapshot ? 0 : 1
    }
    var reducedMotion = false {
        didSet { childNode(withName: "sea").flatMap { $0 as? SKSpriteNode }?.shader?.uniformNamed("u_motion")?.floatValue = seaMotion }
    }

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = UIColor(red: 0.025, green: 0.16, blue: 0.24, alpha: 1)
        addChild(WorldSeaSurface.make(motion: seaMotion))
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
        constrainCamera()
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
        expeditionLayer.zPosition = 6
        addChild(expeditionLayer)
    }

    func setExpeditions(_ values: [WorldExpedition]) {
        expeditions = values
        expeditionLayer.removeAllChildren()
        for voyage in values {
            let color: UIColor = voyage.isRaid ? .systemOrange : .systemTeal
            let container = SKNode()
            container.name = voyage.id
            let path = CGMutablePath()
            path.move(to: point(voyage.origin))
            path.addLine(to: point(voyage.destination))
            let line = SKShapeNode(path: path.copy(dashingWithPhase: 0, lengths: [10, 7]))
            line.name = "line"
            line.strokeColor = color.withAlphaComponent(0.8)
            container.addChild(line)
            let marker = SKShapeNode(circleOfRadius: 11)
            marker.name = "traveler"
            marker.fillColor = UIColor(red: 0.035, green: 0.14, blue: 0.19, alpha: 0.96)
            marker.strokeColor = color
            marker.lineWidth = 2
            let symbol = voyage.isRaid ? "flag.fill" : "person.fill"
            if let symbolImage = UIImage(systemName: symbol) {
                // Rasterize the symbol: SpriteKit cannot reliably resolve a UIKit template image's tint.
                let image = UIGraphicsImageRenderer(size: CGSize(width: 36, height: 36)).image { _ in
                    symbolImage.withTintColor(.white, renderingMode: .alwaysOriginal)
                        .draw(in: CGRect(x: 2, y: 2, width: 32, height: 32))
                }
                let icon = SKSpriteNode(texture: SKTexture(image: image))
                icon.size = CGSize(width: 12, height: 12)
                icon.zPosition = 2
                icon.color = .white
                icon.colorBlendFactor = 1
                marker.addChild(icon)
            }
            if voyage.includesHero && voyage.isRaid {
                let badge = SKLabelNode(text: "H")
                badge.fontName = "AvenirNext-Bold"
                badge.fontSize = 8
                badge.position = CGPoint(x: 10, y: 8)
                badge.fontColor = .white
                marker.addChild(badge)
            }
            container.addChild(marker)
            expeditionLayer.addChild(container)
        }
        updateExpeditions()
    }

    override func update(_ currentTime: TimeInterval) {
        guard currentTime - lastExpeditionUpdate >= (reducedMotion ? 1 : 0.25) else { return }
        lastExpeditionUpdate = currentTime
        updateExpeditions()
    }

    private func updateExpeditions() {
        let now = Date.now
        let frozen = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
            && !ProcessInfo.processInfo.arguments.contains("--snapshot-animate")
        for voyage in expeditions {
            guard let container = expeditionLayer.childNode(withName: voyage.id),
                  let marker = container.childNode(withName: "traveler") else { continue }
            let progress = frozen ? 0.25 : voyage.progress(at: now)
            let fraction = progress <= 0.5 ? progress * 2 : (1 - progress) * 2
            let start = point(voyage.origin), end = point(voyage.destination)
            marker.position = CGPoint(x: start.x + (end.x - start.x) * fraction,
                                      y: start.y + (end.y - start.y) * fraction)
            marker.setScale(viewpoint.xScale)
            (container.childNode(withName: "line") as? SKShapeNode)?.lineWidth = viewpoint.xScale * 1.5
            container.isHidden = progress >= 1
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(world: WorldMap, bots: [BotFaction], selected: TileCoordinate, homes: [TileCoordinate] = [.home], origin: TileCoordinate = .home) {
        self.origin = origin
        self.homes = homes
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
        locations = homes + bots.map(\.capital)
        for tile in homes {
        addVillage(tile: tile, name: tile == .home ? String(localized: "screen.world.amber_harbor", defaultValue: "Port d’Ambre") : String(localized: "expansion.colony", defaultValue: "Colonie"), asset: "MaisonVeilleurs", color: WorldMapStyle.amber)
        }
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
        let node = WorldVillageMarker.make(name: name, asset: asset, color: color, isHome: homes.contains(tile))
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
        if tile != origin {
            let start = point(origin), end = point(tile)
            path.move(to: start)
            path.addQuadCurve(to: end, control: CGPoint(x: (start.x + end.x) / 2 + 50, y: (start.y + end.y) / 2 + 40))
        }
        route.path = path.copy(dashingWithPhase: 0, lengths: [9, 10])
        if focus {
            viewpoint.removeAllActions()
            let destination = cameraBounds.position(point(tile), scale: viewpoint.xScale)
            if reducedMotion { viewpoint.position = destination }
            else { viewpoint.run(.move(to: destination, duration: 0.35)) }
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
            viewpoint.position = cameraBounds.position(
                CGPoint(x: start.x - translation.width * viewpoint.xScale,
                        y: start.y + translation.height * viewpoint.yScale), scale: viewpoint.xScale)
        }
        if ended { dragStart = nil }
    }

    func zoom(_ factor: CGFloat, ended: Bool = true) {
        guard factor.isFinite, factor > 0 else { return }
        viewpoint.removeAllActions()
        if zoomStart == nil { zoomStart = viewpoint.xScale }
        viewpoint.setScale(cameraBounds.scale((zoomStart ?? 2.4) / factor))
        constrainCamera()
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
        constrainCamera()
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
