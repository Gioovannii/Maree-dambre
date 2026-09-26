import SwiftUI

struct ArchipelagoView: View {
    @Environment(GameSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("L’archipel des Veilleurs", systemImage: "location.north.circle")
                    .font(.headline)
                Spacer()
                Text("5 îles").font(.subheadline).foregroundStyle(Palette.muted)
            }
            GeometryReader { geometry in
                ZStack {
                    Canvas { context, size in
                        for row in 0..<12 {
                            let y = CGFloat(row) * size.height / 11
                            var line = Path()
                            line.move(to: CGPoint(x: 0, y: y))
                            line.addQuadCurve(to: CGPoint(x: size.width, y: y), control: CGPoint(x: size.width / 2, y: y + 24))
                            context.stroke(line, with: .color(.white.opacity(0.06)), lineWidth: 1)
                        }
                        var route = Path()
                        for (index, island) in session.game.islands.enumerated() {
                            let point = CGPoint(x: island.x * size.width, y: island.y * size.height)
                            if index == 0 { route.move(to: point) } else { route.addLine(to: point) }
                        }
                        context.stroke(route, with: .color(Palette.amber.opacity(0.22)), style: StrokeStyle(lineWidth: 1, dash: [4, 7]))
                    }
                    .accessibilityHidden(true)
                    ForEach(session.game.islands) { island in
                        Button { session.selectedID = island.id } label: {
                            ZStack {
                                IslandSilhouette()
                                    .fill(island.isHome ? Palette.amber : Color(red: 0.35, green: 0.62, blue: 0.57))
                                    .overlay { IslandSilhouette().stroke(Palette.paper.opacity(0.65), lineWidth: 2) }
                                    .padding(7)
                                Image(systemName: island.isHome ? "building.2.fill" : "leaf.fill")
                                    .foregroundStyle(Palette.ocean).font(.title3)
                            }
                            .frame(width: island.isHome ? 90 : 68, height: island.isHome ? 80 : 60)
                            .background {
                                if session.selectedID == island.id {
                                    Circle().stroke(Palette.paper, style: StrokeStyle(lineWidth: 2, dash: [3, 4]))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(island.name)
                        .accessibilityValue(island.isHome ? "Votre île, port niveau \(island.portLevel)" : "Île inexplorée")
                        .accessibilityAddTraits(session.selectedID == island.id ? .isSelected : [])
                        .position(x: island.x * geometry.size.width, y: island.y * geometry.size.height)
                    }
                }
            }
            .frame(height: 340)
            Text("Touchez une île pour l’explorer").font(.subheadline).foregroundStyle(Palette.muted)
            // Text controls remain readable at every Dynamic Type size.
            ViewThatFits(in: .horizontal) {
                HStack { islandPicker }
                VStack(alignment: .leading) { islandPicker }
            }
        }
        .padding(20)
        .background(Palette.panel, in: .rect(cornerRadius: 28))
    }

    private var islandPicker: some View {
        ForEach(session.game.islands) { island in
            Button { session.selectedID = island.id } label: {
                Text(island.name).font(.subheadline)
                    .padding(.horizontal, 10).frame(minHeight: 44)
                    .background(session.selectedID == island.id ? Palette.ocean : .clear, in: .capsule)
            }
            .foregroundStyle(session.selectedID == island.id ? Palette.amber : Palette.paper)
            .accessibilityAddTraits(session.selectedID == island.id ? .isSelected : [])
        }
    }
}
