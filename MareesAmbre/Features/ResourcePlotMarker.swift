import SwiftUI

/// Only levels and selection change; the resource sites are painted into the map.
struct ResourcePlotMarker: View {
    let site: ResourceSiteKind
    let level: Int
    let selected: Bool
    let size: CGFloat
    let upgrade: ResourceUpgrade?

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                HStack(spacing: 5) {
                    Image(systemName: site.symbol).font(.caption)
                    Text(level, format: .number).font(.subheadline.bold()).monospacedDigit()
                    if selected { Image(systemName: "checkmark").font(.caption.bold()) }
                }
                .foregroundStyle(selected ? Palette.ocean : Palette.paper)
                .padding(.horizontal, 9).frame(minHeight: 32)
                .background(selected ? Palette.amber : Palette.ocean, in: .capsule)
                .overlay { Capsule().strokeBorder(Palette.paper.opacity(0.65), lineWidth: 1) }

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
            .fixedSize(horizontal: true, vertical: false)
            .offset(y: size * 0.30)
        }
        .frame(width: size, height: size)
    }

}
