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
                    VStack(spacing: 4) {
                        Image(systemName: section.symbol)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(width: 42, height: 28)
                            .overlay(alignment: .topTrailing) {
                                if section == .mailbox && unreadCount > 0 {
                                    Text(unreadCount > 99 ? "99+" : unreadCount.formatted())
                                        .font(.system(size: 10, weight: .bold)).monospacedDigit()
                                        .foregroundStyle(Palette.ocean)
                                        .padding(.horizontal, 4).frame(minWidth: 17, minHeight: 17)
                                        .background(Palette.amber, in: .capsule)
                                        .offset(x: 2, y: -1)
                                }
                            }
                        Text(section.title).font(.caption.bold())
                            .lineLimit(typeSize.isAccessibilitySize ? nil : 1)
                            .minimumScaleFactor(typeSize.isAccessibilitySize ? 1 : 0.8)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(.vertical, 4)
                    .foregroundStyle(selected == section ? Palette.amber : Color.white)
                    .background {
                        if selected == section {
                            Capsule()
                                .fill(Palette.amber.opacity(0.22))
                                .overlay {
                                    Capsule().strokeBorder(Palette.amber.opacity(0.65), lineWidth: 1)
                                }
                        }
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
        .padding(5)
        .glassEffect(.regular.tint(Palette.ocean.opacity(0.4)), in: .capsule)

    }
    private var layout: AnyLayout {
        typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 5)) : AnyLayout(HStackLayout(spacing: 2))
    }
}
