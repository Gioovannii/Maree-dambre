import SwiftUI

struct WorldCanvas: View {
    @Environment(VillageSession.self) private var session
    @State private var center = CGPoint(x: 100.5, y: 100.5)
    @State private var cellSize: CGFloat = 28
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
                    for y in minY...maxY {
                        for x in minX...maxX {
                            let tile = TileCoordinate(x: x, y: y)
                            let rect = CGRect(x: origin.x + CGFloat(x) * cellSize, y: origin.y + CGFloat(y) * cellSize, width: cellSize - 1, height: cellSize - 1)
                            let terrain = session.world.terrain(at: tile)
                            context.fill(Path(rect), with: .color(color(for: terrain)))
                            if terrain == .forest && cellSize >= 20 {
                                var tree = Path()
                                tree.move(to: CGPoint(x: rect.midX, y: rect.minY + cellSize * 0.22))
                                tree.addLine(to: CGPoint(x: rect.maxX - cellSize * 0.2, y: rect.maxY - cellSize * 0.2))
                                tree.addLine(to: CGPoint(x: rect.minX + cellSize * 0.2, y: rect.maxY - cellSize * 0.2))
                                tree.closeSubpath()
                                context.fill(tree, with: .color(.black.opacity(0.2)))
                            }
                            if let owner = owners[tile] {
                                context.fill(Path(rect.insetBy(dx: 3, dy: 3)), with: .color(Self.factionColor(owner)))
                                context.draw(Text("\(owner + 1)").font(.caption.bold()).foregroundStyle(Palette.ocean), at: CGPoint(x: rect.midX, y: rect.midY))
                            }
                            if tile == .home {
                                context.fill(Path(ellipseIn: rect.insetBy(dx: 2, dy: 2)), with: .color(Palette.amber))
                                context.draw(Text("★").font(.caption.bold()).foregroundStyle(Palette.ocean), at: CGPoint(x: rect.midX, y: rect.midY))
                            }
                            if tile == session.selectedTile {
                                context.stroke(Path(rect.insetBy(dx: 1, dy: 1)), with: .color(.white), lineWidth: 3)
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
                .simultaneousGesture(MagnifyGesture().onEnded { value in cellSize = min(52, max(12, cellSize * value.magnification)) })
                .simultaneousGesture(SpatialTapGesture().onEnded { value in
                    let x = Int(floor(center.x + (value.location.x - geometry.size.width / 2) / cellSize))
                    let y = Int(floor(center.y + (value.location.y - geometry.size.height / 2) / cellSize))
                    let tile = TileCoordinate(x: x, y: y)
                    if tile.isValid { session.selectedTile = tile }
                })
                .accessibilityLabel("Carte du monde, 200 par 200 cases")
                .accessibilityHint("Utilisez les commandes de coordonnées sous la carte pour choisir une case.")
            }
            .frame(height: 380).clipShape(.rect(cornerRadius: 16))
            HStack {
                Button("Dézoomer", systemImage: "minus.magnifyingglass") { cellSize = max(12, cellSize / 1.3) }
                    .labelStyle(.iconOnly)
                Button("Zoomer", systemImage: "plus.magnifyingglass") { cellSize = min(52, cellSize * 1.3) }
                    .labelStyle(.iconOnly)
                Spacer()
                Button("Mon village", systemImage: "house.fill") { session.selectedTile = .home; focus() }
            }
            .buttonStyle(.bordered).controlSize(.large)
            Text("Glissez pour explorer · Pincez pour zoomer · Touchez une case")
                .font(.footnote).foregroundStyle(Palette.muted)
            DisclosureGroup("Navigation par coordonnées") {
                VStack(spacing: 12) {
                    Stepper("Colonne : \(session.selectedTile.x)", onIncrement: { move(dx: 1, dy: 0) }, onDecrement: { move(dx: -1, dy: 0) })
                    Stepper("Ligne : \(session.selectedTile.y)", onIncrement: { move(dx: 0, dy: 1) }, onDecrement: { move(dx: 0, dy: -1) })
                }
            }
        }
        .onChange(of: session.selectedTile) { focus() }
    }
    private func focus() { center = CGPoint(x: Double(session.selectedTile.x) + 0.5, y: Double(session.selectedTile.y) + 0.5) }
    private func move(dx: Int, dy: Int) {
        session.selectedTile = TileCoordinate(x: min(199, max(0, session.selectedTile.x + dx)), y: min(199, max(0, session.selectedTile.y + dy)))
    }
    private func clamped(_ point: CGPoint) -> CGPoint {
        CGPoint(x: min(199.5, max(0.5, point.x)), y: min(199.5, max(0.5, point.y)))
    }
    private func color(for terrain: Terrain) -> Color {
        switch terrain {
        case .sea: Color(red: 0.08, green: 0.24, blue: 0.30)
        case .meadow: Color(red: 0.39, green: 0.51, blue: 0.34)
        case .forest: Color(red: 0.20, green: 0.37, blue: 0.27)
        case .amber: Color(red: 0.68, green: 0.52, blue: 0.27)
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
