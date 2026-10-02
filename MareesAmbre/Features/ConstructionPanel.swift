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
                    Text(construction != nil ? L10n.text("CHANTIER", "CONSTRUCTION") : building == nil ? L10n.text("PARCELLE", "PLOT") : L10n.text("BÂTIMENT", "BUILDING"))
                        .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                    Text(title).font(.title2.bold()).fontDesign(.serif)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text("\(mode == .resourceFields ? L10n.text("CHAMP", "FIELD") : "LOT") \(mode.slotNumber(for: session.plot) ?? 0)")
                    .font(.caption.bold()).foregroundStyle(Palette.muted)
                    .padding(.top, 4)
            }
            .accessibilityElement(children: .combine)

            Label(L10n.text("Terrain : \(terrain.name) · \(mode.title)", "Terrain: \(terrain.name) · \(mode.title)"), systemImage: "square.dashed")
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
                Button(L10n.text("Annuler le déplacement", "Cancel move"), systemImage: "xmark") {
                    session.cancelMovingBuilding()
                }
                .font(.subheadline.bold())
                .tint(Palette.muted)
                .accessibilityHint(L10n.text("Le bâtiment reste sur la case \(source + 1)", "The building stays on plot \(source + 1)"))
            } else if !mode.contains(session.plot) || siteBuildings.isEmpty {
                Label(L10n.text("Aucune construction possible ici", "Cannot build here"), systemImage: "lock.fill")
                    .font(.headline).foregroundStyle(Palette.muted)
                Text(L10n.text("Ce terrain n’accueille aucun bâtiment de ce district.", "No building in this district can be built on this terrain."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
            } else if availableBuildings.isEmpty {
                Label(L10n.text("Tous les bâtiments sont déjà présents", "All buildings are already present"), systemImage: "checkmark.seal.fill")
                    .font(.headline).foregroundStyle(Palette.amber)
                Text(L10n.text("Chaque type de bâtiment se construit une seule fois dans ce village. Les autres lots accueilleront de nouveaux bâtiments plus tard.", "Each building type can only be built once per village. Other lots will host future buildings."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(L10n.text("Choisissez un bâtiment, puis son emplacement sur la carte. Son effet commence une fois le chantier terminé.", "Choose a building for this plot. Its effect begins when construction finishes."))
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
        return mode == .resourceFields ? L10n.text("Champ de \(terrain.name.lowercased())", "\(terrain.name) field") : L10n.text("Emplacement urbain", "Town lot")
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
                    Text(L10n.text("Requiert un terrain « \(site.name) » au niveau 10. Le bâtiment est conservé et sa production reprendra dès ce prérequis atteint.", "Requires a level 10 \(site.name) site. The building is retained and production resumes once this requirement is met."))
                        .font(.footnote).foregroundStyle(Palette.amber)
                }
                Text(session.state.meetsProductionRequirement(kind) ? L10n.text("Production continue, y compris pendant votre absence.", "Production continues, including while you are away.") : L10n.text("Améliorez le terrain correspondant pour activer cette production.", "Upgrade the matching resource site to activate production."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            if kind != .hall {
                Label(L10n.text("Maintenez le bâtiment appuyé pour le déplacer", "Touch and hold the building to move it"), systemImage: "hand.tap")
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
                Text(L10n.text("Chantier en cours", "Construction in progress"))
                    .font(.title3.bold())
                Text(L10n.text("\(job.kind.name) prend forme sur cette parcelle.", "\(job.kind.name) is taking shape on this plot."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                ProgressView(value: progress)
                    .tint(Palette.amber)
                HStack {
                    Label(progress >= 1 ? L10n.text("Terminé", "Complete") : L10n.text("Encore \(max(0, Int(ceil(job.endsAt.timeIntervalSince(timeline.date)))) ) s", "\(max(0, Int(ceil(job.endsAt.timeIntervalSince(timeline.date)))) ) s remaining"), systemImage: "timer")
                    Spacer()
                    Text("\(Int(progress * 100)) %").bold().foregroundStyle(Palette.amber)
                }
                Button(L10n.text("Annuler le chantier", "Cancel construction"), systemImage: "xmark.circle") {
                    session.cancelConstruction()
                }
                .frame(maxWidth: .infinity, minHeight: 46)
                .buttonStyle(.bordered)
                .tint(Palette.amber)
                Text(L10n.text("Remboursement : 50 % du coût de construction.", "Refund: 50% of the construction cost."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .padding(16)
        .background(Palette.ocean, in: .rect(cornerRadius: 18))
    }

    private func buildingCard(_ kind: BuildingKind) -> some View {
        let canBuild = session.state.canBuild(kind, at: session.plot)
        let reason = session.state.construction != nil ? L10n.text("Un chantier est déjà en cours", "Construction is already in progress")
            : !session.state.meetsProductionRequirement(kind) ? L10n.text("Requiert un terrain « \(kind.requiredResourceSite?.name ?? "producteur") » au niveau 10", "Requires a level 10 \(kind.requiredResourceSite?.name ?? "resource") site")
            : L10n.text("Ressources insuffisantes", "Not enough resources")
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
                Text(L10n.text("Coût : \(kind.cost.wood) bois · \(kind.cost.amber) ambre · \(kind.cost.provisions) vivres", "Cost: \(kind.cost.wood) wood · \(kind.cost.amber) amber · \(kind.cost.provisions) food"))
                    .font(.footnote).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Label(canBuild ? L10n.text("Choisir l’emplacement", "Build here") : reason,
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
        .accessibilityHint(canBuild ? L10n.text("Construire sur la parcelle sélectionnée", "Build on the selected plot") : reason)
    }
}
