import SwiftUI

struct ResourceUpgradeStatus: View {
    let job: ResourceUpgrade
    var allowsCancellation = false
    @Environment(VillageSession.self) private var session

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack(alignment: .leading, spacing: 8) {
                Label(L10n.text("\(ResourceSiteKind.at(job.plot)?.name ?? "Terrain") · Niveau \(job.targetLevel)", "\(ResourceSiteKind.at(job.plot)?.name ?? "Site") · Level \(job.targetLevel)"), systemImage: "hammer.fill")
                    .font(.subheadline.bold())
                HStack {
                    Text(L10n.text("Amélioration en cours", "Upgrade in progress"))
                    Spacer()
                    Text(timerInterval: min(timeline.date, job.endsAt)...job.endsAt, countsDown: true)
                        .monospacedDigit().fixedSize()
                }
                .font(.caption)
                ProgressView(value: job.progress(at: timeline.date)).tint(Palette.amber)
                if allowsCancellation {
                    Text(L10n.text("La production actuelle continue. Le nouveau niveau sera actif à la fin du chantier.", "Current production continues. The new level takes effect when construction finishes."))
                        .font(.footnote)
                    Button(L10n.text("Annuler · remboursement de 50 %", "Cancel · 50% refund"), role: .destructive) {
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
