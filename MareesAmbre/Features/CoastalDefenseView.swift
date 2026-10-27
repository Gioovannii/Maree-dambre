import SwiftUI

struct CoastalDefenseView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if session.state.beginnerProtection != nil {
                    Section { BeginnerProtectionPanel() }.listRowBackground(Palette.panel)
                }
                Section { RaidReminderPanel() }.listRowBackground(Palette.panel)
                Section {
                    ScheduledBotAttackPanel()
                    Text(String(localized: "screen.defense.corsairs", defaultValue: "Les tribus voisines convoitent les réserves de Port d’Ambre."))
                    Text(String(localized: "defense.scheduled.rules", defaultValue: "Les attaques annoncées se résolvent automatiquement avec les troupes présentes au village. Vous n’avez aucun tour à faire avancer. La protection nocturne et celle des débutants restent actives."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .listRowBackground(Palette.panel)

                Section(String(localized: "screen.defense.garrison", defaultValue: "Garnison du village")) {
                    Text(String(localized: "screen.defense.power", defaultValue: "Défense disponible : \(String(session.state.garrisonDefense))"))
                        .font(.headline).accessibilityIdentifier("defense.power")
                    ForEach(ArmyUnit.allCases.filter { session.state.availableArmy[$0, default: 0] > 0 }) { unit in
                        Text(String(localized: "screen.defense.unit_power", defaultValue: "\(String(unit.name)) : \(String(session.state.availableArmy[unit, default: 0])) · Défense par unité : \(String(session.state.defenseStrength(of: unit)))"))
                    }
                    Text(String(localized: "screen.defense.fortifications", defaultValue: "Fortifications et peuple : \(String(session.state.automaticDefense)) points inclus dans la défense."))
                    Text(String(localized: "screen.defense.garrison_rules", defaultValue: "Toutes les troupes présentes défendent le port. Les unités en expédition ou encore en formation ne participent pas. La Tour ajoute 20 de défense ; les armes ajoutent 1 par niveau et par unité."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .listRowBackground(Palette.panel)
                if let report = session.state.coastalCampaign?.report {
                    Section(String(localized: "screen.defense.latest_report", defaultValue: "Dernier rapport de défense")) {
                        DefenseReportView(report: report)
                            .accessibilityIdentifier("defense.report")
                    }
                    .listRowBackground(Palette.panel)
                }

            }
            .scrollContentBackground(.hidden).background(Palette.ocean)
            .foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "screen.defense.title", defaultValue: "Défense du port"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "screen.raid.close", defaultValue: "Fermer"), action: dismiss.callAsFunction)
                }
            }
        }
        .tint(Palette.amber)
    }
}
