import SwiftUI

struct ResourceUpgradeStatus: View {
    let job: ResourceUpgrade
    var allowsCancellation = false
    @Environment(VillageSession.self) private var session

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack(alignment: .leading, spacing: 8) {
                Label("\(ResourceSiteKind.at(job.plot)?.name ?? "Terrain") · Niveau \(job.targetLevel)", systemImage: "hammer.fill")
                    .font(.subheadline.bold())
                HStack {
                    Text("Amélioration en cours")
                    Spacer()
                    Text(timerInterval: min(timeline.date, job.endsAt)...job.endsAt, countsDown: true)
                        .monospacedDigit().fixedSize()
                }
                .font(.caption)
                ProgressView(value: job.progress(at: timeline.date)).tint(Palette.amber)
                if allowsCancellation {
                    Text("La production actuelle continue. Le nouveau niveau sera actif à la fin du chantier.")
                        .font(.footnote)
                    Button("Annuler · remboursement de 50 %", role: .destructive) {
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
