import SwiftUI

/// Only levels and selection change; the resource sites are painted into the map.
struct ResourcePlotMarker: View {
    let level: Int
    let selected: Bool
    let size: CGFloat
    let upgrade: ResourceUpgrade?

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                TideLevelBadge(level: level, selected: selected)

                if let upgrade {
                    Text(timerInterval: min(Date.now, upgrade.endsAt)...upgrade.endsAt, countsDown: true)
                        .font(.caption.bold())
                        .monospacedDigit()
                        .foregroundStyle(Palette.paper)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Palette.ocean, in: .capsule)
                }
            }
            .frame(width: size)
            .offset(y: size * 0.30)
        }
        .frame(width: size, height: size)
    }

}
