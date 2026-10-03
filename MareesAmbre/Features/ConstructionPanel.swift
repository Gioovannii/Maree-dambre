import SwiftUI

struct ConstructionPanel: View {
    let mode: VillageMapMode
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    private var terrain: Terrain { VillageState.ground(at: session.plot) }
    private var building: BuildingKind? { session.state.buildings[session.plot] }
    private var construction: ConstructionJob? {
        guard let job = session.state.construction, job.plot == session.plot else { return nil }
        return job
    }
    private var siteBuildings: [BuildingKind] {
        BuildingKind.constructible(in: mode).filter { $0.suits(terrain) }
    }
    private var availableBuildings: [BuildingKind] {
        siteBuildings.filter { !session.state.hasBuilding($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(construction != nil ? String(localized: "screen.construction.construction", defaultValue: "CHANTIER") : building == nil ? String(localized: "screen.construction.plot", defaultValue: "PARCELLE") : String(localized: "screen.construction.building", defaultValue: "BÂTIMENT"))
                        .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                    Text(title).font(.title2.bold()).fontDesign(.serif)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text(String(localized: "screen.construction.slot_number", defaultValue: "\(String(mode == .resourceFields ? String(localized: "screen.construction.field", defaultValue: "CHAMP") : String(localized: "screen.construction.lot", defaultValue: "LOT"))) \(String(mode.slotNumber(for: session.plot) ?? 0))"))
                    .font(.caption.bold()).foregroundStyle(Palette.muted)
                    .padding(.top, 4)
            }
            .accessibilityElement(children: .combine)

            Label(String(localized: "screen.construction.terrain_value_value", defaultValue: "Terrain : \(String(terrain.name)) · \(String(mode.title))"), systemImage: "square.dashed")
                .font(.subheadline)
                .foregroundStyle(Palette.muted)

            if let job = session.state.construction, job.plot == session.plot {
                constructionDetails(job)
            } else if let building {
                buildingDetails(building)
                if building == .warCourt { ArmyPanel(isTraining: true) }
                if building == .academy { ResearchPanel() }
            } else if let source = session.moveSourcePlot {
                Label(session.message, systemImage: "hand.tap")
                    .font(.subheadline).foregroundStyle(Palette.amber)
                    .fixedSize(horizontal: false, vertical: true)
                Button(String(localized: "screen.construction.cancel_move", defaultValue: "Annuler le déplacement"), systemImage: "xmark") {
                    session.cancelMovingBuilding()
                }
                .font(.subheadline.bold())
                .tint(Palette.muted)
                .accessibilityHint(String(localized: "screen.construction.the_building_stays_on_plot_value", defaultValue: "Le bâtiment reste sur la case \(String(source + 1))"))
            } else if !mode.contains(session.plot) || siteBuildings.isEmpty {
                Label(String(localized: "screen.construction.cannot_build_here", defaultValue: "Aucune construction possible ici"), systemImage: "lock.fill")
                    .font(.headline).foregroundStyle(Palette.muted)
                Text(String(localized: "screen.construction.no_building_in_this_district_can_be_built_on_this_terrain", defaultValue: "Ce terrain n’accueille aucun bâtiment de ce district."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
            } else if availableBuildings.isEmpty {
                Label(String(localized: "screen.construction.all_buildings_are_already_present", defaultValue: "Tous les bâtiments sont déjà présents"), systemImage: "checkmark.seal.fill")
                    .font(.headline).foregroundStyle(Palette.amber)
                Text(String(localized: "screen.construction.each_building_type_can_only_be_built_once_per_village_other_lots_will_host_future_bui", defaultValue: "Chaque type de bâtiment se construit une seule fois dans ce village. Les autres lots accueilleront de nouveaux bâtiments plus tard."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(String(localized: "screen.construction.choose_a_building_for_this_plot_its_effect_begins_when_construction_finishes", defaultValue: "Choisissez un bâtiment, puis son emplacement sur la carte. Son effet commence une fois le chantier terminé."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(availableBuildings) { kind in
                    buildingCard(kind)
                }
            }
        }
        .foregroundStyle(Palette.paper)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 24))
    }

    private var title: String {
        if let construction { return construction.kind.name }
        if let building { return building.name }
        return mode == .resourceFields ? String(localized: "screen.construction.value_field", defaultValue: "Champ de \(String(terrain.name.lowercased()))") : String(localized: "screen.construction.town_lot", defaultValue: "Emplacement urbain")
    }

    private func buildingDetails(_ kind: BuildingKind) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                BuildingArt(kind: kind).frame(width: 76, height: 76)
                VStack(alignment: .leading, spacing: 8) {
                    Text(kind.purpose)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                    Label(session.state.meetsProductionRequirement(kind) ? kind.productionText : "Production inactive", systemImage: kind.defenseStrength > 0 ? "shield.fill" : "arrow.up.right")
                        .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            if kind.yield != Resources(wood: 0, amber: 0, provisions: 0) {
                if let site = kind.requiredResourceSite, !session.state.meetsProductionRequirement(kind) {
                    Text(String(localized: "screen.construction.requires_a_level_10_value_site_the_building_is_retained_and_production_resumes_once_t", defaultValue: "Requiert un terrain « \(String(site.name)) » au niveau 10. Le bâtiment est conservé et sa production reprendra dès ce prérequis atteint."))
                        .font(.footnote).foregroundStyle(Palette.amber)
                }
                Text(session.state.meetsProductionRequirement(kind) ? String(localized: "screen.construction.production_continues_including_while_you_are_away", defaultValue: "Production continue, y compris pendant votre absence.") : String(localized: "screen.construction.upgrade_the_matching_resource_site_to_activate_production", defaultValue: "Améliorez le terrain correspondant pour activer cette production."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            if kind != .hall {
                Label(String(localized: "screen.construction.touch_and_hold_the_building_to_move_it", defaultValue: "Maintenez le bâtiment appuyé pour le déplacer"), systemImage: "hand.tap")
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .padding(16)
        .background(Palette.ocean, in: .rect(cornerRadius: 18))
    }

    private func constructionDetails(_ job: ConstructionJob) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let progress = job.progress(at: timeline.date)
            VStack(alignment: .leading, spacing: 14) {
                ConstructionSiteArt()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Palette.ocean, in: .rect(cornerRadius: 18))
                Text(String(localized: "screen.construction.construction_in_progress", defaultValue: "Chantier en cours"))
                    .font(.title3.bold())
                Text(String(localized: "screen.construction.value_is_taking_shape_on_this_plot", defaultValue: "\(String(job.kind.name)) prend forme sur cette parcelle."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                ProgressView(value: progress)
                    .tint(Palette.amber)
                HStack {
                    Label(progress >= 1 ? String(localized: "screen.construction.complete", defaultValue: "Terminé") : String(localized: "screen.construction.value_s_remaining", defaultValue: "Encore \(String(max(0, Int(ceil(job.endsAt.timeIntervalSince(timeline.date)))) )) s"), systemImage: "timer")
                    Spacer()
                    Text(String(localized: "screen.construction_panel.value", defaultValue: "\(String(Int(progress * 100))) %")).bold().foregroundStyle(Palette.amber)
                }
                Button(String(localized: "screen.construction.cancel_construction", defaultValue: "Annuler le chantier"), systemImage: "xmark.circle") {
                    session.cancelConstruction()
                }
                .frame(maxWidth: .infinity, minHeight: 46)
                .buttonStyle(.bordered)
                .tint(Palette.amber)
                Text(String(localized: "screen.construction.refund_50_of_the_construction_cost", defaultValue: "Remboursement : 50 % du coût de construction."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .padding(16)
        .background(Palette.ocean, in: .rect(cornerRadius: 18))
    }

    private func buildingCard(_ kind: BuildingKind) -> some View {
        let canBuild = session.state.canBuild(kind, at: session.plot)
        let reason = session.state.construction != nil ? String(localized: "screen.construction.construction_is_already_in_progress", defaultValue: "Un chantier est déjà en cours")
            : !session.state.meetsProductionRequirement(kind) ? String(localized: "screen.construction.requires_a_level_10_value_site", defaultValue: "Requiert un terrain « \(String(kind.requiredResourceSite?.name ?? String(localized: "screen.construction.production_site", defaultValue: "producteur"))) » au niveau 10")
            : String(localized: "screen.construction.not_enough_resources", defaultValue: "Ressources insuffisantes")
        return Button {
            session.build(kind)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    BuildingArt(kind: kind).frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(kind.name).font(.headline)
                        Text(kind.productionText)
                            .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                Text(kind.purpose)
                    .font(.subheadline).foregroundStyle(Palette.paper)
                    .fixedSize(horizontal: false, vertical: true)
                Text(String(localized: "screen.construction.cost_value_wood_value_amber_value_food", defaultValue: "Coût : \(String(kind.cost.wood)) bois · \(String(kind.cost.amber)) ambre · \(String(kind.cost.provisions)) vivres"))
                    .font(.footnote).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Label(canBuild ? String(localized: "screen.construction.build_here", defaultValue: "Choisir l’emplacement") : reason,
                      systemImage: canBuild ? "hammer.fill" : "lock.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(canBuild ? Palette.amber : Palette.muted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.ocean, in: .rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(canBuild ? Palette.amber.opacity(0.45) : .white.opacity(0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(!canBuild)
        .accessibilityHint(canBuild ? String(localized: "screen.construction.build_on_the_selected_plot", defaultValue: "Construire sur la parcelle sélectionnée") : reason)
    }
}
