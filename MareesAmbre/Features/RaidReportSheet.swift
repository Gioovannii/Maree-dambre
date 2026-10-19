import SwiftUI

struct RaidReportSheet: View {
    let report: RaidReport
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                RaidReportView(report: report)
                    .padding(18)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
            }
            .background(Palette.ocean)
            .navigationTitle(String(localized: "battle.report.title", defaultValue: "Rapport de combat"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "screen.raid.close", defaultValue: "Fermer")) { dismiss() }
                }
            }
        }
        .tint(Palette.amber)
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
