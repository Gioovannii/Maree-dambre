import SwiftUI

struct WorldCanvas: View {
    @Environment(VillageSession.self) private var session
    @State private var center = CGPoint(x: 100.5, y: 100.5)
    @State private var cellSize: CGFloat = 9
    @GestureState private var drag = CGSize.zero

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                Canvas { context, size in
                    let origin = CGPoint(x: size.width / 2 - center.x * cellSize + drag.width,
                                         y: size.height / 2 - center.y * cellSize + drag.height)
                    let minX = max(0, min(199, Int(floor(-origin.x / cellSize))))
                    let maxX = max(0, min(199, Int(ceil((size.width - origin.x) / cellSize))))
                    let minY = max(0, min(199, Int(floor(-origin.y / cellSize))))
                    let maxY = max(0, min(199, Int(ceil((size.height - origin.y) / cellSize))))
                    let owners = Dictionary(session.state.bots.flatMap { bot in bot.territory.map { ($0, bot.id) } }, uniquingKeysWith: { first, _ in first })
                    drawSea(context: context, size: size, origin: origin)
                    let elevation = coastlineSamples(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
                    var land = Path()
                    var coast = Path()
                    for y in max(0, minY - 1)...min(199, maxY + 1) {
                        for x in max(0, minX - 1)...min(199, maxX + 1) {
                            appendCoast(x: x, y: y, origin: origin, elevation: elevation, land: &land, coast: &coast)
                        }
                    }
                    context.stroke(coast, with: .color(.cyan.opacity(0.10)), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    context.stroke(coast, with: .color(.cyan.opacity(0.18)), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    context.fill(land, with: .color(Color(red: 0.22, green: 0.36, blue: 0.33)))
                    context.stroke(coast, with: .color(Palette.paper.opacity(0.50)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    for y in minY...maxY {
                        for x in minX...maxX {
                            let tile = TileCoordinate(x: x, y: y)
                            let point = CGPoint(x: origin.x + (CGFloat(x) + 0.5) * cellSize,
                                                y: origin.y + (CGFloat(y) + 0.5) * cellSize)
                            let terrain = session.world.terrain(at: tile)
                            if terrain == .forest && cellSize >= 8 && (elevation[tile] ?? 0) > 0.58 {
                                let grove = CGRect(x: point.x - cellSize * 0.22, y: point.y - cellSize * 0.22,
                                                   width: cellSize * 0.44, height: cellSize * 0.44)
                                context.fill(Path(ellipseIn: grove), with: .color(.black.opacity(0.16)))
                            } else if terrain == .amber && cellSize >= 8 && (elevation[tile] ?? 0) > 0.58 {
                                context.draw(Text("✧").font(.caption).foregroundStyle(Palette.amber), at: point)
                            }
                            if let owner = owners[tile] {
                                let mark = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
                                context.fill(Path(ellipseIn: mark), with: .color(Self.factionColor(owner)))
                            }
                            if tile == .home || session.state.bots.contains(where: { $0.capital == tile }) {
                                let ring = CGRect(x: point.x - 15, y: point.y - 15, width: 30, height: 30)
                                context.fill(Path(ellipseIn: ring), with: .color(Palette.ocean))
                                context.stroke(Path(ellipseIn: ring), with: .color(Palette.amber), lineWidth: 1.5)
                                let symbol = tile == .home ? "⚑" : "\((owners[tile] ?? 0) + 1)"
                                context.draw(Text(symbol).font(.headline).foregroundStyle(Palette.paper), at: point)
                            }
                            if tile == session.selectedTile {
                                let ring = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40)
                                context.stroke(Path(ellipseIn: ring), with: .color(Palette.amber), style: StrokeStyle(lineWidth: 2, dash: [3, 5]))
                            }
                        }
                    }
                }
                .background(Palette.ocean).clipped().contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 8)
                    .updating($drag) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        center = clamped(CGPoint(x: center.x - value.translation.width / cellSize, y: center.y - value.translation.height / cellSize))
                    })
                .simultaneousGesture(MagnifyGesture().onEnded { value in cellSize = min(52, max(6, cellSize * value.magnification)) })
                .simultaneousGesture(SpatialTapGesture().onEnded { value in
                    let x = Int(floor(center.x + (value.location.x - geometry.size.width / 2) / cellSize))
                    let y = Int(floor(center.y + (value.location.y - geometry.size.height / 2) / cellSize))
                    let tile = TileCoordinate(x: x, y: y)
                    if tile.isValid { session.selectedTile = tile }
                })
                .accessibilityLabel("Carte du monde, 200 par 200 cases")
                .accessibilityHint("Utilisez les commandes de coordonnées sous la carte pour choisir une case.")
            }
            .frame(height: 360).clipShape(.rect(cornerRadius: 16))
            HStack {
                Button("Dézoomer", systemImage: "minus.magnifyingglass") { cellSize = max(6, cellSize / 1.3) }
                    .labelStyle(.iconOnly)
                Button("Zoomer", systemImage: "plus.magnifyingglass") { cellSize = min(52, cellSize * 1.3) }
                    .labelStyle(.iconOnly)
                Spacer()
                Button("Mon village", systemImage: "house.fill") { session.selectedTile = .home; focus() }
            }
            .buttonStyle(.bordered).controlSize(.large).tint(Palette.amber)
            Text("Glissez pour explorer · Pincez pour zoomer · Touchez un lieu")
                .font(.footnote).foregroundStyle(Palette.muted)
            DisclosureGroup("Navigation par coordonnées") {
                VStack(spacing: 12) {
                    Stepper("Colonne : \(session.selectedTile.x)", onIncrement: { move(dx: 1, dy: 0) }, onDecrement: { move(dx: -1, dy: 0) })
                    Stepper("Ligne : \(session.selectedTile.y)", onIncrement: { move(dx: 0, dy: 1) }, onDecrement: { move(dx: 0, dy: -1) })
                }
            }
        }
        .tint(Palette.amber)
        .onChange(of: session.selectedTile) { focus() }
    }
    private func focus() { center = CGPoint(x: Double(session.selectedTile.x) + 0.5, y: Double(session.selectedTile.y) + 0.5) }
    private func move(dx: Int, dy: Int) {
        session.selectedTile = TileCoordinate(x: min(199, max(0, session.selectedTile.x + dx)), y: min(199, max(0, session.selectedTile.y + dy)))
    }
    private func clamped(_ point: CGPoint) -> CGPoint {
        CGPoint(x: min(199.5, max(0.5, point.x)), y: min(199.5, max(0.5, point.y)))
    }
    private func drawSea(context: GraphicsContext, size: CGSize, origin: CGPoint) {
        for row in -1...Int(size.height / 34) + 1 {
            var current = Path()
            let y = CGFloat(row) * 34 + origin.y.truncatingRemainder(dividingBy: 34)
            current.move(to: CGPoint(x: -20, y: y))
            current.addCurve(to: CGPoint(x: size.width + 20, y: y - 35),
                             control1: CGPoint(x: size.width * 0.3, y: y + 55),
                             control2: CGPoint(x: size.width * 0.65, y: y - 65))
            context.stroke(current, with: .color(.cyan.opacity(row.isMultiple(of: 3) ? 0.10 : 0.04)), lineWidth: 1)
        }
    }

    // Smooth only the illustration. Terrain, ownership and saved world coordinates stay authoritative.
    private func coastlineSamples(minX: Int, maxX: Int, minY: Int, maxY: Int) -> [TileCoordinate: Double] {
        var samples: [TileCoordinate: Double] = [:]
        for y in max(0, minY - 1)...min(200, maxY + 2) {
            for x in max(0, minX - 1)...min(200, maxX + 2) {
                var total = 0.0
                var weights = 0.0
                for dy in -3...3 {
                    for dx in -3...3 {
                        let weight = Double((4 - abs(dx)) * (4 - abs(dy)))
                        weights += weight
                        if session.world.terrain(at: TileCoordinate(x: x + dx, y: y + dy)) != .sea {
                            total += weight
                        }
                    }
                }
                samples[TileCoordinate(x: x, y: y)] = total / weights
            }
        }
        return samples
    }

    /// Interpolate the coastline between tile centres; selection still uses the original world coordinates.
    private func appendCoast(x: Int, y: Int, origin: CGPoint, elevation: [TileCoordinate: Double], land: inout Path, coast: inout Path) {
        let coordinates = [TileCoordinate(x: x, y: y), TileCoordinate(x: x + 1, y: y),
                           TileCoordinate(x: x + 1, y: y + 1), TileCoordinate(x: x, y: y + 1)]
        let points = coordinates.map { CGPoint(x: origin.x + (CGFloat($0.x) + 0.5) * cellSize,
                                               y: origin.y + (CGFloat($0.y) + 0.5) * cellSize) }
        let values = coordinates.map { elevation[$0] ?? 0 }
        let solid = values.map { $0 >= 0.5 }
        for indices in [[0, 1, 2], [0, 2, 3]] {
            var polygon: [CGPoint] = []
            var crossings: [CGPoint] = []
            for i in 0..<3 {
                let a = indices[i]
                let b = indices[(i + 1) % 3]
                if solid[a] { polygon.append(points[a]) }
                if solid[a] != solid[b] {
                    let fraction = (0.5 - values[a]) / (values[b] - values[a])
                    let midpoint = CGPoint(x: points[a].x + (points[b].x - points[a].x) * fraction,
                                           y: points[a].y + (points[b].y - points[a].y) * fraction)
                    polygon.append(midpoint)
                    crossings.append(midpoint)
                }
            }
            if let first = polygon.first {
                land.move(to: first)
                for point in polygon.dropFirst() { land.addLine(to: point) }
                land.closeSubpath()
            }
            if crossings.count == 2 {
                coast.move(to: crossings[0])
                coast.addLine(to: crossings[1])
            }
        }
    }
    static func factionColor(_ id: Int) -> Color {
        switch id {
        case 0: Color(red: 0.94, green: 0.57, blue: 0.40)
        case 1: Color(red: 0.60, green: 0.74, blue: 0.95)
        default: Color(red: 0.80, green: 0.65, blue: 0.89)
        }
    }
}
