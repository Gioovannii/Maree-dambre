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
                        Text(String(localized: "screen.resource_site.resource_site", defaultValue: "TERRAIN PRODUCTEUR"))
                            .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                        Text(kind.name)
                            .font(.title2.bold()).fontDesign(.serif)
                    }
                    Spacer(minLength: 0)
                    Text(String(localized: "screen.resource_site.site_value", defaultValue: "ZONE \(String(VillageMapMode.resourceFields.slotNumber(for: session.plot) ?? 0))"))
                        .font(.caption.bold()).foregroundStyle(Palette.muted)
                }

                Label(String(localized: "screen.resource_site.level_value_of_value", defaultValue: "Niveau \(String(level)) sur \(String(ResourceSiteKind.maximumLevel))"), systemImage: kind.symbol)
                    .font(.headline)
                    .foregroundStyle(Palette.paper)

                let rate = kind.yieldPerLevel
                let hourly = max(rate.wood, rate.amber, rate.provisions) * level
                Label(String(localized: "screen.resource_site.value_value_per_hour", defaultValue: "+\(String(hourly)) \(String(kind.yieldLabel)) par heure"), systemImage: "clock.arrow.circlepath")
                    .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                Text(String(localized: "screen.resource_site.harvesting_continues_while_you_are_away_resources_are_automatically_added_to_village", defaultValue: "La récolte continue pendant votre absence. Les ressources rejoignent automatiquement le stock du village."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text(String(localized: "screen.resource_site.one_level_10_site_of_this_type_unlocks_its_production_building_in_town", defaultValue: "Un seul terrain de ce type au niveau 10 débloque son bâtiment de production au Centre."))
                    .font(.footnote).foregroundStyle(Palette.amber)
                if let job = session.state.resourceUpgrade, job.plot == session.plot {
                    ResourceUpgradeStatus(job: job, allowsCancellation: true)
                } else if level < ResourceSiteKind.maximumLevel {
                    let nextLevel = level + 1
                    let cost = kind.cost(for: nextLevel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(level == 0 ? String(localized: "screen.resource_site.develop_site", defaultValue: "Développer le terrain") : String(localized: "screen.resource_site.upgrade_to_level_value", defaultValue: "Améliorer au niveau \(String(nextLevel))"))
                            .font(.headline)
                        Text(String(localized: "screen.resource_site.gain_value_value_h", defaultValue: "Gain : +\(String(max(rate.wood, rate.amber, rate.provisions))) \(String(kind.yieldLabel)) / h"))
                            .font(.subheadline).foregroundStyle(Palette.amber)
                        Text(String(localized: "screen.resource_site.cost_value_wood_value_amber_value_food", defaultValue: "Coût : \(String(cost.wood)) bois · \(String(cost.amber)) ambre · \(String(cost.provisions)) vivres"))
                            .font(.subheadline).foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(String(localized: "screen.resource_site.duration_1_minute", defaultValue: "Durée : 1 minute"))
                            .font(.subheadline).foregroundStyle(Palette.muted)
                        if session.state.construction != nil || session.state.resourceUpgrade != nil {
                            Text(String(localized: "screen.resource_site.finish_or_cancel_the_current_construction_before_starting_this_upgrade", defaultValue: "Terminez ou annulez le chantier en cours avant de commencer cette amélioration."))
                                .font(.footnote).foregroundStyle(Palette.amber)
                        }
                        Button(String(localized: "screen.resource_site.upgrade", defaultValue: "Améliorer"), systemImage: "arrow.up.circle.fill") {
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
                    Label(String(localized: "screen.resource_site.site_at_maximum_level", defaultValue: "Terrain au niveau maximal"), systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 24))
    }
}
