import SwiftUI

struct GameNavigationBar: View {
    let selected: GameSection
    let unreadCount: Int
    let onSelect: (GameSection) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        layout {
            ForEach(GameSection.allCases) { section in
                Button { onSelect(section) } label: {
                    VStack(spacing: 5) {
                        Image(systemName: section.symbol)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(width: 25, height: 23)
                            .overlay(alignment: .topTrailing) {
                                if section == .mailbox && unreadCount > 0 {
                                    Text(unreadCount > 99 ? "99+" : unreadCount.formatted())
                                        .font(.system(size: 10, weight: .bold)).monospacedDigit()
                                        .foregroundStyle(Palette.ocean)
                                        .padding(.horizontal, 4).frame(minWidth: 17, minHeight: 17)
                                        .background(Palette.amber, in: .capsule)
                                        .offset(x: 11, y: -6)
                                }
                            }
                        Text(section.title).font(.caption2.bold())
                            .lineLimit(typeSize.isAccessibilitySize ? nil : 1)
                            .minimumScaleFactor(typeSize.isAccessibilitySize ? 1 : 0.8)
                    }
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .padding(.vertical, 3)
                    .foregroundStyle(selected == section ? Palette.amber : Palette.muted)
                    .background {
                        if selected == section { Capsule().fill(.white.opacity(0.12)) }
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(section.title)
                .accessibilityValue(section == .mailbox && unreadCount > 0
                    ? String(localized: "mail.unread_count", defaultValue: "\(String(unreadCount)) non lus") : "")
                .accessibilityAddTraits(selected == section ? .isSelected : [])
                .accessibilityIdentifier("navigation.\(String(describing: section))")
            }
        }
        .padding(4)
        .glassEffect(.clear.interactive(), in: .capsule)

    }
    private var layout: AnyLayout {
        typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 5)) : AnyLayout(HStackLayout(spacing: 2))
    }
}
