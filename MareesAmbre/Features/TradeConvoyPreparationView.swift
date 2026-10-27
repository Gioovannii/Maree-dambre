import SwiftUI

struct TradeConvoyPreparationView: View {
    let route: TradeRoute
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var selections = ArmyUnit.allCases.map { RaidTroopSelection(unit: $0) }
    @State private var departureFailed = false

    private var selected: [ArmyUnit: Int] {
        Dictionary(uniqueKeysWithValues: selections.filter { $0.count > 0 }.map { ($0.unit, $0.count) })
    }
    private var remaining: [ArmyUnit: Int] {
        session.state.availableArmy.reduce(into: [:]) { result, entry in
            result[entry.key] = max(0, entry.value - selected[entry.key, default: 0])
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(route.name).font(.headline)
                        Text(TradeRoute.partner)
                        Text(String(localized: "screen.commerce.cargo", defaultValue: "Chaque contrat : 20 bois livrés et 5 vivres consommés au départ."))
                        Text(GameProgression.durationText(route.travelDuration)).font(.subheadline)

                        Text(route == .sheltered
                             ? String(localized: "screen.commerce.safe_route", defaultValue: "Route protégée : aucune perte dans l’escorte.")
                             : String(localized: "screen.commerce.risky_route", defaultValue: "Pillards sur la route : force 24. Une escorte de force 24 ou plus livre la cargaison ; une escorte plus faible la perd."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                }
                .listRowBackground(Palette.panel)
                Section(String(localized: "screen.commerce.choose_escort", defaultValue: "Répartir l’escorte")) {
                    Button(String(localized: "screen.raid.keep_half", defaultValue: "Garder la moitié au village"), systemImage: "shield", action: { select(all: false) })
                    Button(String(localized: "screen.raid.select_all", defaultValue: "Tout sélectionner"), systemImage: "checkmark.circle", action: { select(all: true) })
                        .accessibilityIdentifier("commerce.selectAll")
                    ForEach($selections) { $selection in
                        let available = session.state.availableArmy[selection.unit, default: 0]
                        if available > 0 {
                            RaidTroopSelectionRow(selection: $selection, available: available, accessibilityPrefix: "convoy")
                        }
                    }
                }
                .listRowBackground(Palette.panel)
                Section(String(localized: "screen.raid.summary", defaultValue: "Répartition")) {
                    Text(String(localized: "screen.commerce.escort_strength", defaultValue: "Force de l’escorte : \(String(session.state.armyPower(for: selected)))"))
                        .accessibilityIdentifier("commerce.escortPower")
                    Text(String(localized: "screen.commerce.transport", defaultValue: "Transport : \(String(session.state.convoyCapacity(for: selected))) / 20 nécessaires"))
                    Text(String(localized: "screen.raid.remaining_defense", defaultValue: "Défense du port après départ : \(String(session.state.defensePower(for: remaining)))"))
                        .accessibilityIdentifier("commerce.remainingDefense")

                    if let report = session.state.convoyPreview(on: route, units: selected, now: .now) {
                        ConvoyReportView(report: report, isPreview: true)
                    } else {
                        Text(String(localized: "screen.commerce.selection_help", defaultValue: "Choisissez une escorte avec assez de transport. Vérifiez aussi la cargaison, le Marché et la disponibilité de l’offre."))
                            .font(.footnote)
                    }
                    Text(String(localized: "screen.commerce.departure_rules", defaultValue: "Armes, mages, Infirmerie et transport sont fixés au départ. Les survivants reviennent au village ; le paiement est conservé au comptoir jusqu’à récupération."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                    if departureFailed {
                        Text(String(localized: "screen.commerce.departure_failed", defaultValue: "Le contrat ou l’escorte ne sont plus disponibles. Vérifiez votre sélection."))
                    }
                    Button(action: send) {
                        AdaptiveActionLabel(title: String(localized: "screen.commerce.send", defaultValue: "Envoyer le convoi"), systemImage: "sailboat.fill")
                    }
                    .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                    .disabled(!session.state.canSendConvoy(on: route, units: selected, now: .now))
                    .accessibilityIdentifier("commerce.send")
                }
                .listRowBackground(Palette.panel)
            }
            .scrollContentBackground(.hidden).background(Palette.ocean).foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "screen.commerce.prepare", defaultValue: "Choisir l’escorte"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "screen.raid.close", defaultValue: "Fermer"), action: dismiss.callAsFunction)
            } }
        }
        .tint(Palette.amber)
        .onChange(of: session.state.availableArmy) { _, _ in
            selections = clampedSelections(selections, to: session.state.availableArmy)
            departureFailed = false
        }
    }

    private func select(all: Bool) {
        selections = selectedUnits(from: session.state.availableArmy, all: all)
        departureFailed = false
    }

    private func selectedUnits(from available: [ArmyUnit: Int], all: Bool) -> [RaidTroopSelection] {
        ArmyUnit.allCases.map { unit in
            RaidTroopSelection(unit: unit, count: available[unit, default: 0] / (all ? 1 : 2))
        }
    }

    private func clampedSelections(_ current: [RaidTroopSelection], to available: [ArmyUnit: Int]) -> [RaidTroopSelection] {
        current.map { selection in
            RaidTroopSelection(
                unit: selection.unit,
                count: min(selection.count, available[selection.unit, default: 0])
            )
        }
    }

    private func send() {
        if session.sendConvoy(on: route, units: selected) { dismiss() }
        else { setDepartureFailed() }
    }

    private func setDepartureFailed() {
        departureFailed = true
    }
}
