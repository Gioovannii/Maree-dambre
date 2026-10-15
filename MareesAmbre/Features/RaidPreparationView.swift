import SwiftUI

struct RaidPreparationView: View {
    let target: BotFaction
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var selections = ArmyUnit.allCases.map { RaidTroopSelection(unit: $0) }
    @State private var departureFailed = false

    private var currentTarget: BotFaction {
        session.state.bots.first(where: { $0.id == target.id }) ?? target
    }
    private var deployed: [ArmyUnit: Int] {
        Dictionary(uniqueKeysWithValues: selections.filter { $0.count > 0 }.map { ($0.unit, $0.count) })
    }
    private var deployedCount: Int { deployed.values.reduce(0, +) }
    private var remainingCount: Int { session.state.availableArmy.values.reduce(0, +) - deployedCount }
    private var remainingUnits: [ArmyUnit: Int] {
        session.state.availableArmy.reduce(into: [:]) { result, entry in
            result[entry.key] = max(0, entry.value - deployed[entry.key, default: 0])
        }
    }
    private var power: Int { session.state.armyPower(for: deployed) }
    private var defense: Int { 10 + min(10, currentTarget.level) * 4 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(currentTarget.displayName).font(.headline)
                    Text(String(localized: "screen.army.defense_value", defaultValue: "Défense : \(String(defense))"))
                    Text(String(localized: "screen.raid.duration", defaultValue: "Aller-retour : \(String(Int(session.state.raidDuration))) secondes."))
                }
                .listRowBackground(Palette.panel)
                Section(String(localized: "screen.raid.choose_units", defaultValue: "Choisir les troupes")) {
                    Button(String(localized: "screen.raid.select_all", defaultValue: "Tout sélectionner"), systemImage: "checkmark.circle", action: selectAll)
                        .accessibilityIdentifier("raid.selectAll")
                    Button(String(localized: "screen.raid.keep_half", defaultValue: "Garder la moitié au village"), systemImage: "shield", action: selectHalf)
                        .accessibilityIdentifier("raid.keepHalf")
                    ForEach($selections) { $selection in
                        let available = session.state.availableArmy[selection.unit, default: 0]
                        if available > 0 {
                            RaidTroopSelectionRow(selection: $selection, available: available)
                        }
                    }
                }
                .listRowBackground(Palette.panel)
                Section(String(localized: "screen.raid.summary", defaultValue: "Répartition")) {
                    Text(String(localized: "screen.raid.deployed_summary", defaultValue: "Envoyées : \(String(deployedCount)) · Force : \(String(power))"))
                        .accessibilityIdentifier("raid.deployedSummary")
                    Text(String(localized: "screen.raid.remaining_summary", defaultValue: "Au village : \(String(max(0, remainingCount)))"))
                        .accessibilityIdentifier("raid.remainingSummary")
                    Text(String(localized: "screen.raid.remaining_defense", defaultValue: "Défense du port après départ : \(String(session.state.defensePower(for: remainingUnits)))"))
                        .accessibilityIdentifier("raid.remainingDefense")
                    if let campaign = session.state.coastalCampaign {
                        Text(String(localized: "screen.defense.incoming", defaultValue: "Assaut dans \(String(campaign.tidesUntilAssault)) marée(s) · Force ennemie : \(String(campaign.enemyPower))"))
                            .font(.footnote)
                    }
                    Text(String(localized: "screen.raid.remaining_help", defaultValue: "Les troupes gardées au village restent disponibles. Les troupes envoyées sont mobilisées jusqu’au retour."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                    if deployedCount > 0 {
                        RaidOutcomePreview(units: deployed, defense: defense)
                    } else {
                        Text(String(localized: "screen.raid.empty_selection", defaultValue: "Choisissez au moins une unité pour préparer le départ."))
                            .font(.footnote)
                    }
                    if departureFailed {
                        Text(String(localized: "screen.raid.departure_failed", defaultValue: "Les troupes ou la cible ne sont plus disponibles. Vérifiez votre sélection."))
                            .font(.footnote)
                    }
                    Button(String(localized: "screen.raid.send_selection", defaultValue: "Envoyer les troupes choisies"), systemImage: "sailboat.fill", action: send)
                        .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                        .disabled(!session.state.canRaid(currentTarget, units: deployed))
                        .accessibilityIdentifier("raid.send")
                }
                .listRowBackground(Palette.panel)
            }
            .scrollContentBackground(.hidden)
            .background(Palette.ocean)
            .foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "screen.army.prepare_attack", defaultValue: "Préparer l’attaque"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "screen.raid.close", defaultValue: "Fermer"), action: dismiss.callAsFunction)
                }
            }
        }
        .tint(Palette.amber)
        .onChange(of: session.state.availableArmy) { _, _ in clampSelection() }
    }

    private func selectAll() {
        for index in selections.indices {
            selections[index].count = session.state.availableArmy[selections[index].unit, default: 0]
        }
        departureFailed = false
    }

    private func selectHalf() {
        for index in selections.indices {
            selections[index].count = session.state.availableArmy[selections[index].unit, default: 0] / 2
        }
        departureFailed = false
    }

    private func clampSelection() {
        for index in selections.indices {
            selections[index].count = min(selections[index].count,
                session.state.availableArmy[selections[index].unit, default: 0])
        }
    }

    private func send() {
        if session.raid(target.id, units: deployed) { dismiss() }
        else { departureFailed = true }
    }
}
