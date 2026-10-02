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
                        Text(L10n.text("TERRAIN PRODUCTEUR", "RESOURCE SITE"))
                            .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                        Text(kind.name)
                            .font(.title2.bold()).fontDesign(.serif)
                    }
                    Spacer(minLength: 0)
                    Text(L10n.text("ZONE \(VillageMapMode.resourceFields.slotNumber(for: session.plot) ?? 0)", "SITE \(VillageMapMode.resourceFields.slotNumber(for: session.plot) ?? 0)"))
                        .font(.caption.bold()).foregroundStyle(Palette.muted)
                }

                Label(L10n.text("Niveau \(level) sur \(ResourceSiteKind.maximumLevel)", "Level \(level) of \(ResourceSiteKind.maximumLevel)"), systemImage: kind.symbol)
                    .font(.headline)
                    .foregroundStyle(Palette.paper)

                let rate = kind.yieldPerLevel
                let hourly = max(rate.wood, rate.amber, rate.provisions) * level
                Label(L10n.text("+\(hourly) \(kind.yieldLabel) par heure", "+\(hourly) \(kind.yieldLabel) per hour"), systemImage: "clock.arrow.circlepath")
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                Text(L10n.text("La récolte continue pendant votre absence. Les ressources rejoignent automatiquement le stock du village.", "Harvesting continues while you are away. Resources are automatically added to village storage."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.text("Un seul terrain de ce type au niveau 10 débloque son bâtiment de production au Centre.", "One level 10 site of this type unlocks its production building in town."))
                    .font(.footnote).foregroundStyle(Palette.amber)
                if let job = session.state.resourceUpgrade, job.plot == session.plot {
                    ResourceUpgradeStatus(job: job, allowsCancellation: true)
                } else if level < ResourceSiteKind.maximumLevel {
                    let nextLevel = level + 1
                    let cost = kind.cost(for: nextLevel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(level == 0 ? L10n.text("Développer le terrain", "Develop site") : L10n.text("Améliorer au niveau \(nextLevel)", "Upgrade to level \(nextLevel)"))
                            .font(.headline)
                        Text(L10n.text("Gain : +\(max(rate.wood, rate.amber, rate.provisions)) \(kind.yieldLabel) / h", "Gain: +\(max(rate.wood, rate.amber, rate.provisions)) \(kind.yieldLabel) / h"))
                            .font(.subheadline).foregroundStyle(Palette.amber)
                        Text(L10n.text("Coût : \(cost.wood) bois · \(cost.amber) ambre · \(cost.provisions) vivres", "Cost: \(cost.wood) wood · \(cost.amber) amber · \(cost.provisions) food"))
                            .font(.subheadline).foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(L10n.text("Durée : 1 minute", "Duration: 1 minute"))
                            .font(.subheadline).foregroundStyle(Palette.muted)
                        if session.state.construction != nil || session.state.resourceUpgrade != nil {
                            Text(L10n.text("Terminez ou annulez le chantier en cours avant de commencer cette amélioration.", "Finish or cancel the current construction before starting this upgrade."))
                                .font(.footnote).foregroundStyle(Palette.amber)
                        }
                        Button(L10n.text("Améliorer", "Upgrade"), systemImage: "arrow.up.circle.fill") {
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
                    Label(L10n.text("Terrain au niveau maximal", "Site at maximum level"), systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 24))
    }
}
