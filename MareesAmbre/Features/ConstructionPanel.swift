import SwiftUI

struct ConstructionPanel: View {
    let mode: VillageMapMode
    @Environment(VillageSession.self) private var session

    private var siteBuildings: [BuildingKind] {
        BuildingKind.constructible(in: mode).filter { $0.suits(VillageState.ground(at: session.plot)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CHANTIER").font(.caption.bold()).tracking(2).foregroundStyle(Palette.amber)
                    Text(title).font(.title2.bold()).fontDesign(.serif)
                }
                Spacer()
                Text("\(mode == .resourceFields ? "CHAMP" : "LOT") \(mode.slotNumber(for: session.plot) ?? 0)")
                    .font(.caption.bold()).foregroundStyle(Palette.muted)
            }

            if let building = session.state.buildings[session.plot] {
                HStack(spacing: 16) {
                    BuildingArt(kind: building).frame(width: 70, height: 68)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(building.name).font(.headline)
                        Label(building.productionText, systemImage: "arrow.up.right")
                            .font(.subheadline).foregroundStyle(Palette.amber)
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
                .background(Palette.ocean, in: .rect(cornerRadius: 18))
            } else if !mode.contains(session.plot) || siteBuildings.isEmpty {
                Label(VillageState.ground(at: session.plot).name, systemImage: terrainSymbol)
                    .font(.headline)
                    .foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
                Text(mode == .resourceFields ? "Ce terrain n’accueille pas de champ de production." : "Choisissez un emplacement libre du centre-ville.")
                    .font(.subheadline).foregroundStyle(Palette.muted)
            } else {
                Text(mode == .resourceFields ? "Chaque champ produit en continu." : "Développez les défenses et les réserves du village.")
                    .font(.subheadline).foregroundStyle(Palette.muted)

                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(siteBuildings) { kind in
                            buildingCard(kind)
                        }
                    }
                    .padding(.vertical, 3)
                }
                .scrollIndicators(.hidden)
                Text("Balayez pour parcourir les bâtiments")
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
        .padding(18)
        .background(Palette.panel, in: .rect(cornerRadius: 24))
    }

    private var title: String {
        if let building = session.state.buildings[session.plot] { return building.name }
        return mode == .resourceFields ? "Champ de \(VillageState.ground(at: session.plot).name.lowercased())" : "Emplacement urbain"
    }

    private var terrainSymbol: String {
        switch VillageState.ground(at: session.plot) {
        case .sea: "water.waves"
        case .forest: "tree.fill"
        case .amber: "sparkles"
        case .meadow: "plus"
        }
    }

    private func buildingCard(_ kind: BuildingKind) -> some View {
        let canBuild = session.state.canBuild(kind, at: session.plot)

        return Button { session.build(kind) } label: {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .center) {
                    BuildingArt(kind: kind).frame(width: 52, height: 48)
                    Spacer()
                    Image(systemName: kind.symbol).foregroundStyle(Palette.amber)
                }
                Text(kind.name).font(.headline).lineLimit(1)
                Text(kind.productionText).font(.subheadline).foregroundStyle(Palette.amber)
                Text("\(kind.cost.wood) bois · \(kind.cost.amber) ambre · \(kind.cost.provisions) vivres")
                    .font(.footnote).foregroundStyle(Palette.muted).lineLimit(2)
            }
            .frame(width: 166, alignment: .leading)
            .padding(14)
            .background(Palette.ocean, in: .rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(canBuild ? Palette.amber.opacity(0.3) : .white.opacity(0.06), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(!canBuild)
        .opacity(canBuild ? 1 : 0.5)
        .accessibilityHint(canBuild ? "Construire sur la parcelle sélectionnée" : "Ressources insuffisantes")
    }
}
