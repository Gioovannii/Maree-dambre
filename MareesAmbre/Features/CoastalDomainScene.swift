import SwiftUI

/// Native rendering of the approved concept. Gameplay and UI remain outside this layer.
struct CoastalDomainScene: View {
    var mode: VillageMapMode = .resourceFields

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var epoch = Date.now

    private let snapshot = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
        && !ProcessInfo.processInfo.arguments.contains("--snapshot-animate")

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                Image(mode.assetName)
                    .resizable().interpolation(.high)
                if !reduceMotion {
                    TimelineView(.animation(minimumInterval: 1.0 / 24, paused: snapshot || scenePhase != .active)) { timeline in
                        let time = snapshot ? snapshotTime : timeline.date.timeIntervalSince(epoch).truncatingRemainder(dividingBy: 6)
                        Canvas { context, canvasSize in
                            drawWater(context: context, size: canvasSize, time: time)
                            drawFoam(context: context, size: canvasSize, time: time)
                        }
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var snapshotTime: Double {
        let argument = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--snapshot-motion-phase=") }
        guard let value = argument?.split(separator: "=").last.flatMap({ Double($0) }), value.isFinite else { return 0 }
        return min(6, max(0, value))
    }

    private func drawWater(context: GraphicsContext, size: CGSize, time: Double) {
        var sea = context
        sea.clip(to: CoastalSeaMask(mode: mode).path(in: CGRect(origin: .zero, size: size)))
        let image = sea.resolve(Image(mode.assetName))
        let phase = time * .pi / 3
        // Thin resampling bands bend the existing water texture without a custom
        // shader/toolchain. Skip the entire inland region to bound per-frame work.
        for row in stride(from: 0, to: 1774, by: 6) where row < (mode == .townCenter ? 275 : 270) || row >= 1272 {
            let y = Double(row)
            var band = sea
            band.clip(to: Path(CGRect(x: 0, y: y / 1774 * size.height,
                                     width: size.width, height: 6 / 1774 * size.height)))
            let dx = (4.5 * sin(y * 0.028 + phase) + 1.5 * sin(y * 0.07 - phase * 2)) / 887 * size.width
            let dy = 2.0 * cos(y * 0.035 - phase) / 1774 * size.height
            band.draw(image, in: CGRect(x: dx, y: dy, width: size.width, height: size.height))
        }
    }

    private func drawFoam(context: GraphicsContext, size: CGSize, time: Double) {
        var sea = context
        sea.clip(to: CoastalSeaMask(mode: mode).path(in: CGRect(origin: .zero, size: size)))
        let phase = time * .pi / 3
        let glints: [CGPoint] = mode == .townCenter
            ? [CGPoint(x: 600, y: 120), CGPoint(x: 720, y: 190), CGPoint(x: 430, y: 1450),
               CGPoint(x: 550, y: 1530), CGPoint(x: 670, y: 1630), CGPoint(x: 400, y: 1720)]
            : [CGPoint(x: 155, y: 160), CGPoint(x: 350, y: 211),
                                 CGPoint(x: 440, y: 1400), CGPoint(x: 480, y: 1430),
                                 CGPoint(x: 660, y: 1575), CGPoint(x: 350, y: 1740)]
        for (index, point) in glints.enumerated() {
            let offset = Double(index) * 0.8
            let x = (point.x + 7 * sin(phase + offset)) / 887 * size.width
            let y = (point.y + 3 * cos(phase + offset)) / 1774 * size.height
            var stroke = Path()
            stroke.move(to: CGPoint(x: x, y: y))
            stroke.addQuadCurve(to: CGPoint(x: x + size.width * 0.035, y: y),
                                control: CGPoint(x: x + size.width * 0.018, y: y - 2))
            sea.stroke(stroke, with: .color(Palette.paper.opacity(0.22 + 0.10 * sin(phase + offset))),
                       style: StrokeStyle(lineWidth: max(0.5, size.width / 887), lineCap: .round))
        }
    }
}
