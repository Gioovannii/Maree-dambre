import SwiftUI

struct AbsenceSummaryBanner: View {
    @Environment(VillageSession.self) private var session
    @State private var showsSummary = ProcessInfo.processInfo.arguments.contains("--snapshot-absence")
    let summary: AbsenceSummary
    let onShowMessages: () -> Void
    var compact = false

    var body: some View {
        Button {
            showsSummary = true
        } label: {
            HStack(spacing: 10) {
                if compact {
                    Image(systemName: "sun.horizon.fill")
                } else {
                    Label(String(localized: "absence.title", defaultValue: "Pendant votre absence"), systemImage: "sun.horizon.fill")
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").accessibilityHidden(true)
                }
            }
            .font(.subheadline.bold())
            .foregroundStyle(Palette.amber)
            .padding(12)
            .frame(maxWidth: compact ? nil : .infinity, minHeight: 44)
            .background(Palette.panel, in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "absence.title", defaultValue: "Pendant votre absence"))
        .sheet(isPresented: $showsSummary, onDismiss: { session.dismissAbsenceSummary() }) {
            AbsenceSummarySheet(summary: summary) {
                showsSummary = false
                onShowMessages()
            }
        }
    }
}
