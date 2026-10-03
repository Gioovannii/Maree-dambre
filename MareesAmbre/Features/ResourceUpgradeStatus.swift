import SwiftUI

struct ResourceUpgradeStatus: View {
    let job: ResourceUpgrade
    var allowsCancellation = false
    @Environment(VillageSession.self) private var session

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack(alignment: .leading, spacing: 8) {
                Label(String(localized: "screen.resource_upgrade_status.value_level_value", defaultValue: "\(String(ResourceSiteKind.at(job.plot)?.name ?? String(localized: "screen.resource_upgrade_status.resource_site", defaultValue: "Terrain"))) · Niveau \(String(job.targetLevel))"), systemImage: "hammer.fill")
                    .font(.subheadline.bold())
                HStack {
                    Text(String(localized: "screen.resource_upgrade_status.upgrade_in_progress", defaultValue: "Amélioration en cours"))
                    Spacer()
                    Text(timerInterval: min(timeline.date, job.endsAt)...job.endsAt, countsDown: true)
                        .monospacedDigit().fixedSize()
                }
                .font(.caption)
                ProgressView(value: job.progress(at: timeline.date)).tint(Palette.amber)
                if allowsCancellation {
                    Text(String(localized: "screen.resource_upgrade_status.current_production_continues_the_new_level_takes_effect_when_construction_finishes", defaultValue: "La production actuelle continue. Le nouveau niveau sera actif à la fin du chantier."))
                        .font(.footnote)
                    Button(String(localized: "screen.resource_upgrade_status.cancel_50_refund", defaultValue: "Annuler · remboursement de \((0.5).formatted(.percent.precision(.fractionLength(0))))"), role: .destructive) {
                        session.cancelResourceUpgrade()
                    }
                    .frame(minHeight: 44)
                }
            }
            .foregroundStyle(Palette.paper)
            .padding(12)
            .background(Palette.panel, in: .rect(cornerRadius: 16))
        }
    }
}
