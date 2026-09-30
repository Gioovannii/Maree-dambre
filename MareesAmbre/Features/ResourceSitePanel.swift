import SwiftUI

struct ResourceSitePanel: View {
    @Environment(VillageSession.self) private var session

    private var kind: ResourceSiteKind? { ResourceSiteKind.at(session.plot) }
    private var level: Int { session.state.resourceLevel(at: session.plot) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let kind {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TERRAIN PRODUCTEUR")
                            .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                        Text(kind.name)
                            .font(.title2.bold()).fontDesign(.serif)
                    }
                    Spacer(minLength: 0)
                    Text("ZONE \(VillageMapMode.resourceFields.slotNumber(for: session.plot) ?? 0)")
                        .font(.caption.bold()).foregroundStyle(Palette.muted)
                }

                Label("Niveau \(level) sur \(ResourceSiteKind.maximumLevel)", systemImage: kind.symbol)
                    .font(.headline)
                    .foregroundStyle(Palette.paper)

                let rate = kind.yieldPerLevel
                let hourly = max(rate.wood, rate.amber, rate.provisions) * level
                Label("+\(hourly) \(kind.yieldLabel) par heure", systemImage: "clock.arrow.circlepath")
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                Text("La récolte continue pendant votre absence. Les ressources rejoignent automatiquement le stock du village.")
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Un seul terrain de ce type au niveau 10 débloque son bâtiment de production au Centre.")
                    .font(.footnote).foregroundStyle(Palette.amber)
                if let job = session.state.resourceUpgrade, job.plot == session.plot {
                    ResourceUpgradeStatus(job: job, allowsCancellation: true)
                } else if level < ResourceSiteKind.maximumLevel {
                    let nextLevel = level + 1
                    let cost = kind.cost(for: nextLevel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(level == 0 ? "Développer le terrain" : "Améliorer au niveau \(nextLevel)")
                            .font(.headline)
                        Text("Gain : +\(max(rate.wood, rate.amber, rate.provisions)) \(kind.yieldLabel) / h")
                            .font(.subheadline).foregroundStyle(Palette.amber)
                        Text("Coût : \(cost.wood) bois · \(cost.amber) ambre · \(cost.provisions) vivres")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Durée : 1 minute")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                        if session.state.construction != nil || session.state.resourceUpgrade != nil {
                            Text("Terminez ou annulez le chantier en cours avant de commencer cette amélioration.")
                                .font(.footnote).foregroundStyle(Palette.amber)
                        }
                        Button("Améliorer", systemImage: "arrow.up.circle.fill") {
                            session.developSelectedResource()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.amber)
                        .foregroundStyle(Palette.ocean)
                        .disabled(!session.state.canDevelopResource(at: session.plot))
                    }
                    .padding(16)
                    .background(Palette.ocean, in: .rect(cornerRadius: 18))
                } else {
                    Label("Terrain au niveau maximal", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 24))
    }
}
