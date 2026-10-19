import SwiftUI
import TipKit

struct ExpansionView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var role: SettlementRole = .production
    @State private var escort: ArmyUnit = .tideguard
    @State private var confirmsDeparture = false
    private var village: VillageState { session.state }
    private var target: TileCoordinate { session.selectedTile }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Label(String(localized: "expansion.title", defaultValue: "Un nouveau rivage"), systemImage: "sailboat.fill")
                        .font(.title.bold()).fontDesign(.serif).foregroundStyle(Palette.amber)
                    Text(String(localized: "expansion.intro", defaultValue: "Une capitale et deux colonies au maximum. Chaque implantation possède ses réserves, ses bâtiments et sa garnison."))
                        .foregroundStyle(Palette.muted)
                    if village.location != .home {
                        Text(String(localized: "expansion.capital_only", defaultValue: "Les expéditions de fondation se préparent dans la capitale."))
                        Button(String(localized: "expansion.return_capital", defaultValue: "Gérer la capitale")) { session.switchSettlement(to: .home) }
                            .buttonStyle(.borderedProminent)
                    } else if village.settlementCount >= VillageState.maximumSettlements {
                        Label(String(localized: "expansion.limit", defaultValue: "Votre domaine a atteint ses trois implantations."), systemImage: "checkmark.seal.fill")
                    } else {
                        requirements
                        if let voyage = village.expansion?.voyage {
                            Label(String(localized: "expansion.at_sea", defaultValue: "Expédition en mer"), systemImage: "sailboat.fill").font(.headline)
                            Text(position(voyage.destination))
                            Text(voyage.role.name)
                            Text(voyage.arrivesAt, style: .timer).monospacedDigit().foregroundStyle(Palette.amber)
                            Text(String(localized: "expansion.arrival", defaultValue: "À l’arrivée, la colonie apparaîtra dans vos implantations. Les cinq soldats y resteront en garnison."))
                        } else {
                            preparation
                            destination
                            departure
                        }
                    }
                    Text(session.message).font(.footnote).foregroundStyle(Palette.muted)
                }
                .padding(20).frame(maxWidth: 650, alignment: .leading).frame(maxWidth: .infinity)
            }
            .defaultScrollAnchor(ProcessInfo.processInfo.arguments.contains("--snapshot-expansion-departure") ? .bottom : .top)
            .background(Palette.ocean).foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "expansion.navigation", defaultValue: "Colonisation"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "expansion.close", defaultValue: "Fermer")) { dismiss() }
                }
            }
        }
        .tint(Palette.amber).preferredColorScheme(.dark)
        .onAppear { escort = village.peopleUnits.first ?? .tideguard }
        .confirmationDialog(String(localized: "expansion.confirm", defaultValue: "Lancer la fondation ? Les ressources et les colons seront engagés définitivement."), isPresented: $confirmsDeparture, titleVisibility: .visible) {
            Button(String(localized: "expansion.send", defaultValue: "Envoyer les colons")) {
                _ = session.foundColony(at: target, role: role, escort: escort)
            }
        }
    }

    private var requirements: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "expansion.requirements", defaultValue: "Préparer la capitale")).font(.headline)
            requirement(.hall, level: village.settlementCount < 2 ? 5 : 8)
            requirement(.academy, level: village.settlementCount < 2 ? 3 : 5)
            requirement(.expeditionQuay, level: village.settlementCount < 2 ? 2 : 3)
            requirement(.warehouse, level: village.settlementCount < 2 ? 3 : 7)
            Text(String(localized: "expansion.storage", defaultValue: "L’entrepôt demandé peut contenir chaque ressource nécessaire à la fondation."))
                .font(.caption).foregroundStyle(Palette.muted)
        }
        .padding(16).background(Palette.panel, in: .rect(cornerRadius: 18))
    }

    private func requirement(_ kind: BuildingKind, level: Int) -> some View {
        Label(kind.name + " · " + String(localized: "expansion.level", defaultValue: "Niveau") + " " + level.formatted(),
              systemImage: village.buildingLevel(kind) >= level ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(village.buildingLevel(kind) >= level ? Palette.amber : Palette.muted)
    }

    private var preparation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "expansion.preparation", defaultValue: "Navigation et colons")).font(.headline)
            if let end = village.expansion?.researchEndsAt {
                Text(String(localized: "expansion.research.running", defaultValue: "Navigation : recherche en cours"))
                Text(end, style: .timer).monospacedDigit()
            } else if village.expansion?.researched != true {
                ExpansionCostView(cost: VillageState.navigationCost)
                Text(GameProgression.durationText(VillageState.navigationDuration)).font(.caption)
                Button(String(localized: "expansion.research", defaultValue: "Rechercher la navigation"), action: session.researchNavigation)
                    .disabled(!village.canResearchNavigation)
            } else {
                Label(String(localized: "expansion.research.ready", defaultValue: "Navigation maîtrisée"), systemImage: "checkmark.circle.fill")
                if let end = village.expansion?.settlersEndAt {
                    Text(String(localized: "expansion.settlers.running", defaultValue: "Les colons préparent leur départ"))
                    Text(end, style: .timer).monospacedDigit()
                } else if village.expansion?.settlersReady == true {
                    Label(String(localized: "expansion.settlers.ready", defaultValue: "Équipe de colons prête"), systemImage: "person.3.fill")
                } else {
                    ExpansionCostView(cost: VillageState.settlersCost)
                    Text(GameProgression.durationText(VillageState.settlersDuration)).font(.caption)
                    Button(String(localized: "expansion.settlers.prepare", defaultValue: "Préparer les colons"), action: session.prepareSettlers)
                        .disabled(!village.canPrepareSettlers)
                }
            }
        }
        .buttonStyle(.borderedProminent).foregroundStyle(Palette.paper)
    }

    private var destination: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "expansion.destination", defaultValue: "Choisir une terre")).font(.headline)
            Text(String(localized: "expansion.any_site", defaultValue: "Pour choisir un autre lieu, touchez une terre libre sur la carte Monde avant d’ouvrir Colonisation. Les destinations ci-dessous sont des suggestions."))
                .font(.footnote).foregroundStyle(Palette.muted)
            Text(position(target))
            if village.canSettle(at: target, on: session.world) {
                Label(village.isRefugeSite(target)
                      ? String(localized: "expansion.refuge", defaultValue: "Refuge : aucune attaque subie dans cette colonie")
                      : String(localized: "expansion.frontier", defaultValue: "Frontière : campagne de défense disponible"),
                      systemImage: village.isRefugeSite(target) ? "shield.checkered" : "flag.fill")
                Text(GameProgression.durationText(village.foundingDuration(to: target)))
            } else {
                Text(String(localized: "expansion.invalid_site", defaultValue: "Choisissez une terre libre, à huit cases de vos villages et six cases des territoires voisins."))
                    .foregroundStyle(Palette.muted)
            }
            ForEach(village.suggestedSettlementSites(on: session.world), id: \.self) { site in
                Button {
                    session.selectedTile = site
                } label: {
                    Label(position(site) + " · " + (village.isRefugeSite(site)
                          ? String(localized: "expansion.site.refuge", defaultValue: "Refuge")
                          : String(localized: "expansion.site.frontier", defaultValue: "Frontière")),
                          systemImage: target == site ? "checkmark.circle.fill" : "map.fill")
                }
                .buttonStyle(.bordered)
            }
            Text(String(localized: "expansion.specialization", defaultValue: "Spécialisation")).font(.headline)
            Picker(String(localized: "expansion.specialization", defaultValue: "Spécialisation"), selection: $role) {
                ForEach(SettlementRole.allCases) { Text($0.name).tag($0) }
            }
            roleBenefit
        }
    }
    private var roleBenefit: some View { Text(role.benefit).font(.footnote).foregroundStyle(Palette.muted) }

    private var departure: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "expansion.foundation", defaultValue: "Fonder la colonie")).font(.headline)
            ExpansionCostView(cost: village.foundationCost)
            Text(String(localized: "expansion.seed_stock", defaultValue: "La fondation comprend 200 bois, 100 ambre, 200 vivres et trois champs de niveau 1 dans la nouvelle colonie."))
                .font(.footnote).foregroundStyle(Palette.muted)
            Text(String(localized: "expansion.escort", defaultValue: "Escorte : cinq soldats")).font(.headline)
            Picker(String(localized: "expansion.escort", defaultValue: "Escorte : cinq soldats"), selection: $escort) {
                ForEach(village.trainableUnits) { unit in
                    Text(unit.name + " · " + village.availableArmy[unit, default: 0].formatted()).tag(unit)
                }
            }
            Text(String(localized: "expansion.escort.rule", defaultValue: "Cinq soldats quittent la capitale et rejoignent la garnison de la colonie. La traversée de fondation ne provoque pas de combat."))
                .font(.footnote).foregroundStyle(Palette.muted)
            Button(String(localized: "expansion.send", defaultValue: "Envoyer les colons"), systemImage: "sailboat.fill") { confirmsDeparture = true }
                .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                .disabled(!village.canFound(at: target, escort: escort, on: session.world))
                .popoverTip(session.guidedStep == .complete && !ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
                            ? VillageGuideTip(step: .complete, anchor: "colonization") : nil)
                .accessibilityIdentifier("expansion.found")
        }
    }
    private func position(_ tile: TileCoordinate) -> String { "\(tile.x), \(tile.y)" }
}
