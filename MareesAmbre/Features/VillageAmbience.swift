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
                } else {
                    ForEach(0..<4, id: \.self) { index in
                        swayingLeaf(
                            at: CGPoint(x: [0.34, 0.45, 0.62, 0.70][index], y: [0.28, 0.40, 0.34, 0.48][index]),
                            size: geometry.size,
                            delay: Double(index) * 0.45
                        )
                    }
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

    @ViewBuilder
    private func swayingLeaf(at point: CGPoint, size: CGSize, delay: Double) -> some View {
        if reduceMotion {
            Image(systemName: "leaf.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(red: 0.47, green: 0.68, blue: 0.32).opacity(0.9))
                .position(x: size.width * point.x, y: size.height * point.y)
        } else {
            Image(systemName: "leaf.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(red: 0.47, green: 0.68, blue: 0.32).opacity(0.9))
                .phaseAnimator([false, true]) { content, phase in
                    content.rotationEffect(.degrees(phase ? 8 : -8), anchor: .bottom)
                } animation: { _ in
                    .easeInOut(duration: 1.9).repeatForever(autoreverses: true).delay(delay)
                }
                .position(x: size.width * point.x, y: size.height * point.y)
        }
    }
}
