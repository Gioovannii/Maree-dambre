import SwiftUI

struct ConstructionPanel: View {
    let mode: VillageMapMode
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    private var terrain: Terrain { VillageState.ground(at: session.plot) }
    private var building: BuildingKind? { session.state.buildings[session.plot] }
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
                    Text(building == nil ? "PARCELLE" : "BÂTIMENT")
                        .font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                    Text(title).font(.title2.bold()).fontDesign(.serif)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text("\(mode == .resourceFields ? "CHAMP" : "LOT") \(mode.slotNumber(for: session.plot) ?? 0)")
                    .font(.caption.bold()).foregroundStyle(Palette.muted)
                    .padding(.top, 4)
            }
            .accessibilityElement(children: .combine)

            Label("Terrain : \(terrain.name) · \(mode.title)", systemImage: "square.dashed")
                .font(.subheadline)
                .foregroundStyle(Palette.muted)

            if let building {
                buildingDetails(building)
            } else if let source = session.moveSourcePlot {
                Label(session.message, systemImage: "hand.tap")
                    .font(.subheadline).foregroundStyle(Palette.amber)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Annuler le déplacement", systemImage: "xmark") {
                    session.cancelMovingBuilding()
                }
                .font(.subheadline.bold())
                .tint(Palette.muted)
                .accessibilityHint("Le bâtiment reste sur la case \(source + 1)")
            } else if !mode.contains(session.plot) || siteBuildings.isEmpty {
                Label("Aucune construction possible ici", systemImage: "lock.fill")
                    .font(.headline).foregroundStyle(Palette.muted)
                Text("Ce terrain n’accueille aucun bâtiment de ce district.")
                    .font(.subheadline).foregroundStyle(Palette.muted)
            } else if availableBuildings.isEmpty {
                Label("Tous les bâtiments sont déjà présents", systemImage: "checkmark.seal.fill")
                    .font(.headline).foregroundStyle(Palette.amber)
                Text("Chaque type de bâtiment se construit une seule fois dans ce village. Les autres lots accueilleront de nouveaux bâtiments plus tard.")
                    .font(.subheadline).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Choisissez un bâtiment pour cet emplacement. Sa production ou son effet commence dès sa construction et continue hors ligne.")
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
        if let building { return building.name }
        return mode == .resourceFields ? "Champ de \(terrain.name.lowercased())" : "Emplacement urbain"
    }

    private func buildingDetails(_ kind: BuildingKind) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                BuildingArt(kind: kind).frame(width: 76, height: 76)
                VStack(alignment: .leading, spacing: 8) {
                    Text(kind.purpose)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                    Label(kind.productionText, systemImage: kind.defenseStrength > 0 ? "shield.fill" : "arrow.up.right")
                        .font(.subheadline.bold()).foregroundStyle(Palette.amber)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            if kind.yield != Resources(wood: 0, amber: 0, provisions: 0) {
                Text("Production continue, y compris pendant votre absence.")
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            if kind != .hall {
                Button {
                    if session.moveSourcePlot == session.plot {
                        session.cancelMovingBuilding()
                    } else {
                        session.beginMovingSelectedBuilding()
                        dismiss()
                    }
                } label: {
                    Label(session.moveSourcePlot == session.plot ? "Annuler le déplacement" : "Déplacer le bâtiment",
                          systemImage: session.moveSourcePlot == session.plot ? "xmark" : "arrow.up.and.down.and.arrow.left.and.right")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(Palette.amber)
                .accessibilityHint("Choisir une case compatible sur la carte pour réorganiser le village")
            }
        }
        .padding(16)
        .background(Palette.ocean, in: .rect(cornerRadius: 18))
    }

    private func buildingCard(_ kind: BuildingKind) -> some View {
        let canBuild = session.state.canBuild(kind, at: session.plot)
        return Button { session.build(kind) } label: {
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
                Text("Coût : \(kind.cost.wood) bois · \(kind.cost.amber) ambre · \(kind.cost.provisions) vivres")
                    .font(.footnote).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Label(canBuild ? "Construire" : "Ressources insuffisantes",
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
        .accessibilityHint(canBuild ? "Construire sur la parcelle sélectionnée" : "Il manque des ressources pour construire ici")
    }
}
