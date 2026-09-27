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
                    walker(in: geometry.size, start: 0.45, y: 0.56, delay: 0)
                    walker(in: geometry.size, start: 0.57, y: 0.61, delay: 1.8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func smoke(in size: CGSize, diameter: CGFloat, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        if reduceMotion {
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

    @ViewBuilder
    private func walker(in size: CGSize, start: CGFloat, y: CGFloat, delay: Double) -> some View {
        if reduceMotion {
            Image(systemName: "figure.walk")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Palette.ocean.opacity(0.92))
                .position(x: size.width * start, y: size.height * y)
        } else {
            Image(systemName: "figure.walk")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Palette.ocean.opacity(0.92))
                .shadow(color: Palette.paper.opacity(0.8), radius: 2)
                .phaseAnimator([false, true]) { content, phase in
                    content.offset(x: phase ? 42 : -8)
                } animation: { _ in
                    .easeInOut(duration: 5.5).repeatForever(autoreverses: true).delay(delay)
                }
                .position(x: size.width * start, y: size.height * y)
        }
    }

}
