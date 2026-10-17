import SwiftUI

/// Decorative residents follow the paved corridors, clear of every buildable lot.
/// One canvas and one clock keep this independent of the village simulation.
struct VillagePedestrians: View {
    var mode: VillageMapMode = .townCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var startedAt = Date.now

    private let snapshot = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
        && !ProcessInfo.processInfo.arguments.contains("--snapshot-animate")
    private static let townRoutes: [[CGPoint]] = [
        [CGPoint(x: 0.49, y: 0.43), CGPoint(x: 0.49, y: 0.51),
         CGPoint(x: 0.50, y: 0.61), CGPoint(x: 0.49, y: 0.74)],
        [CGPoint(x: 0.08, y: 0.40), CGPoint(x: 0.11, y: 0.49),
         CGPoint(x: 0.12, y: 0.60), CGPoint(x: 0.12, y: 0.68)],
        [CGPoint(x: 0.89, y: 0.42), CGPoint(x: 0.88, y: 0.50),
         CGPoint(x: 0.88, y: 0.60), CGPoint(x: 0.86, y: 0.68)],
        [CGPoint(x: 0.17, y: 0.61), CGPoint(x: 0.37, y: 0.61),
         CGPoint(x: 0.50, y: 0.61), CGPoint(x: 0.78, y: 0.61)]
    ]
    // Feet positions registered to the 887 × 1774 background. Follow the dirt
    // corridors outside fences; never take a straight shortcut across a plot.
    private static let resourceRoutes: [[CGPoint]] = [
        [(472, 286), (439, 310), (407, 336), (376, 365), (367, 394),
         (375, 425), (405, 461), (435, 495), (449, 526), (433, 557), (416, 583)],
        [(117, 399), (167, 419), (222, 441), (280, 455), (337, 456), (375, 425)],
        [(239, 729), (280, 750), (326, 777), (376, 804), (422, 823),
         (469, 811), (514, 788), (558, 764), (602, 741)],
        [(475, 864), (525, 899), (568, 935), (570, 966), (552, 994),
         (526, 1022), (516, 1055), (518, 1095), (506, 1132)],
        [(449, 1197), (414, 1214), (376, 1234), (337, 1254)]
    ].map { points in
        points.map { CGPoint(x: CGFloat($0.0) / 887, y: CGFloat($0.1) / 1774) }
    }
    private static let coats: [Color] = [
        Color(red: 0.18, green: 0.43, blue: 0.44),
        Color(red: 0.70, green: 0.32, blue: 0.20),
        Color(red: 0.79, green: 0.60, blue: 0.27),
        Color(red: 0.32, green: 0.41, blue: 0.32)
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30,
                                paused: reduceMotion || snapshot || scenePhase != .active)) { timeline in
            let time = reduceMotion ? 0 : snapshot ? snapshotTime : max(0, timeline.date.timeIntervalSince(startedAt))
            Canvas { context, size in
                for resident in 0..<(mode == .resourceFields ? 7 : 8) {
                    drawResident(resident, time: time, size: size, context: context)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var snapshotTime: Double {
        let argument = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--snapshot-motion-phase=") }
        guard let value = argument?.split(separator: "=").last.flatMap({ Double($0) }), value.isFinite else { return 0 }
        return min(360, max(0, value))
    }

    private func drawResident(_ index: Int, time: Double, size: CGSize, context: GraphicsContext) {
        let routes = mode == .resourceFields ? Self.resourceRoutes : Self.townRoutes
        let route = routes[index % routes.count]
        let lengths = zip(route, route.dropFirst()).map { start, end in
            hypot((end.x - start.x) * size.width, (end.y - start.y) * size.height)
        }
        let distance = lengths.reduce(0, +)
        guard distance > 0 else { return }
        let scale = max(0.65, size.width / 390)
        let travelTime = distance / ((7 + Double(index % 3)) * scale)
        let pause = 2.5
        let halfCycle = travelTime + pause
        let phase = (time + Double(index) * 11).truncatingRemainder(dividingBy: halfCycle * 2)
        let returning = phase >= halfCycle
        let legTime = returning ? phase - halfCycle : phase
        let walking = legTime < travelTime && !reduceMotion
        let progress = min(legTime / travelTime, 1)
        var remaining = (returning ? 1 - progress : progress) * distance
        var point = route[0]
        var facing: CGFloat = 1
        for segment in lengths.indices {
            let length = lengths[segment]
            if remaining <= length || segment == lengths.count - 1 {
                let fraction = min(remaining / max(length, 0.001), 1)
                let start = route[segment]
                let end = route[segment + 1]
                point = CGPoint(x: start.x + (end.x - start.x) * fraction,
                                y: start.y + (end.y - start.y) * fraction)
                facing = (end.x - start.x) * (returning ? -1 : 1) < 0 ? -1 : 1
                break
            }
            remaining -= length
        }
        let stride = walking ? sin(legTime * 9) : 0
        var painter = context
        painter.translateBy(x: point.x * size.width, y: point.y * size.height)
        painter.scaleBy(x: scale, y: scale)
        painter.fill(Path(ellipseIn: CGRect(x: -3.5, y: -1, width: 8, height: 3)), with: .color(.black.opacity(0.22)))
        painter.scaleBy(x: facing, y: 1)
        func limb(from start: CGPoint, to end: CGPoint, color: Color, width: CGFloat) {
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)
            painter.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
        }
        let boots = Color(red: 0.25, green: 0.20, blue: 0.17)
        limb(from: CGPoint(x: -1.2, y: -4), to: CGPoint(x: -1.5 + stride * 1.7, y: 0), color: boots, width: 1.7)
        limb(from: CGPoint(x: 1.2, y: -4), to: CGPoint(x: 1.5 - stride * 1.7, y: 0), color: boots, width: 1.7)
        let bob = walking ? abs(stride) * 0.5 : 0
        painter.translateBy(x: 0, y: -bob)
        let skin = Color(red: 0.77, green: 0.53, blue: 0.34)
        limb(from: CGPoint(x: -2, y: -8), to: CGPoint(x: -3, y: -4 + stride), color: skin, width: 1.5)
        limb(from: CGPoint(x: 2, y: -8), to: CGPoint(x: 3, y: -4 - stride), color: skin, width: 1.5)
        painter.fill(Path(roundedRect: CGRect(x: -2.5, y: -9, width: 5, height: 6), cornerRadius: 1.5), with: .color(Self.coats[index % 4]))
        painter.fill(Path(ellipseIn: CGRect(x: -2, y: -13, width: 4, height: 4.5)), with: .color(skin))
        painter.fill(Path(ellipseIn: CGRect(x: -2.2, y: -13.5, width: 4.5, height: 2)), with: .color(boots))
        if index.isMultiple(of: 3) {
            painter.fill(Path(ellipseIn: CGRect(x: -3.5, y: -12.5, width: 7, height: 1.7)), with: .color(Self.coats[2]))
        }
        if index.isMultiple(of: 2) {
            painter.fill(Path(roundedRect: CGRect(x: 2, y: -5, width: 3, height: 3), cornerRadius: 0.7), with: .color(Self.coats[2]))
        }
    }
}
