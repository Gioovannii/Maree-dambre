import SwiftUI

/// Lightweight scene motion makes each district feel inhabited without a game engine.
struct VillageAmbience: View {
    let mode: VillageMapMode

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if mode == .townCenter {
                    smoke(in: geometry.size, diameter: 10, x: 0.53, y: 0.31, delay: 0)
                    smoke(in: geometry.size, diameter: 7, x: 0.55, y: 0.28, delay: 0.7)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func smoke(in size: CGSize, diameter: CGFloat, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        if reduceMotion || ProcessInfo.processInfo.arguments.contains("--ui-snapshot") {
            Circle()
                .fill(Palette.paper.opacity(0.24))
                .frame(width: diameter, height: diameter)
                .position(x: x * size.width, y: y * size.height)
        } else {
            Circle()
                .fill(Palette.paper.opacity(0.52))
                .frame(width: diameter, height: diameter)
                .phaseAnimator([false, true]) { content, phase in
                    content
                        .offset(y: phase ? -18 : 1)
                        .scaleEffect(phase ? 1.45 : 0.7)
                        .opacity(phase ? 0.02 : 0.5)
                } animation: { _ in
                    .easeOut(duration: 2.2).repeatForever(autoreverses: false).delay(delay)
                }
                .position(x: x * size.width, y: y * size.height)
        }
    }

}
