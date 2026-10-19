import SwiftUI

struct CoastalDefenseView: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var confirmsAssault = false

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
                    Text(String(localized: "screen.defense.clock_rules_scheduled", defaultValue: "Les assauts réguliers font avancer les marées jusqu’au combat et au retour des convois concernés. Vous pouvez aussi avancer une marée manuellement. Un combat repousse le prochain assaut régulier de 24 h."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .listRowBackground(Palette.panel)
                if let campaign = session.state.coastalCampaign {
                    Section(String(localized: "screen.defense.threat", defaultValue: "Menace annoncée")) {
                        if let convoy = session.state.army?.convoy {
                            Text(String(localized: "screen.commerce.return_tide", defaultValue: "Retour à la marée \(String(convoy.returnsAtTide)), après les combats."))
                                .font(.footnote)
                        }
                        Text(String(localized: "screen.defense.tide", defaultValue: "Marée \(String(campaign.tide))"))
                            .accessibilityIdentifier("defense.tide")
                        Text(campaign.isHighTide
                             ? String(localized: "screen.defense.high_tide", defaultValue: "Marée haute")
                             : String(localized: "screen.defense.low_tide", defaultValue: "Marée basse"))
                        if let attackerID = campaign.attackerID,
                           let attacker = session.state.bots.first(where: { $0.id == attackerID }) {
                            Text(String(localized: "screen.defense.attacker", defaultValue: "Assaillant : \(String(WorldNeighbor.name(for: attacker, seed: session.world.seed))) · \(String(attacker.displayName))"))
                                .font(.headline)
                        }
                        if !session.state.isUnderProtection() {
                        Text(String(localized: "screen.defense.arrival", defaultValue: "\(String(campaign.enemyCount)) pillards · Force \(String(campaign.enemyPower)) · Arrivée à la marée \(String(campaign.nextAssaultTide))"))
                        Text(String(localized: "screen.defense.warning", defaultValue: "Il reste \(String(campaign.tidesUntilAssault)) marée(s) pour préparer la garnison."))
                            .accessibilityIdentifier("defense.warning")
                        } else {
                            Text(String(localized: "protection.tides", defaultValue: "Les marées et les convois continuent. Les assauts contre votre village sont reportés jusqu’à la fin de la protection."))
                                .foregroundStyle(Palette.amber)
                        }
                        Text(String(localized: "screen.defense.scaling", defaultValue: "Les tribus voisines se relaient. Les voisins plus éloignés et les vagues suivantes envoient une force supérieure."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                    .listRowBackground(Palette.panel)
                }
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
                if let preview = session.state.defensePreview {
                    Section(String(localized: "screen.defense.preview", defaultValue: "Estimation avec vos forces et stocks actuels")) {
                        DefenseReportView(report: preview)
                        Text(String(localized: "screen.defense.loss_rules", defaultValue: "À défense égale, le port tient. Les pertes suivent les règles de l’Infirmerie et des mages présents. En défaite, au moins 20 de chaque ressource restent protégés si vous les possédez ; champs et bâtiments sont conservés."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                    .listRowBackground(Palette.panel)
                }
                if let report = session.state.coastalCampaign?.report {
                    Section(String(localized: "screen.defense.latest_report", defaultValue: "Dernier rapport de défense")) {
                        Text(String(localized: "screen.defense.report_tide", defaultValue: "Assaut de la marée \(String(report.tide))"))
                        DefenseReportView(report: report)
                            .accessibilityIdentifier("defense.report")
                    }
                    .listRowBackground(Palette.panel)
                }
                Section {
                    if let campaign = session.state.coastalCampaign {
                        if confirmsAssault && campaign.tidesUntilAssault == 1 && !session.state.isUnderProtection() {
                            Text(String(localized: "screen.defense.confirm_title", defaultValue: "Un voisin attaque à cette marée."))
                                .font(.headline)
                            Text(String(localized: "screen.defense.confirm_message", defaultValue: "Les troupes actuellement au village défendront le port. Le résultat et les pertes seront sauvegardés."))
                                .font(.footnote).foregroundStyle(Palette.muted)
                            Button {
                                session.advanceCoastalTide()
                                confirmsAssault = false
                            } label: {
                                AdaptiveActionLabel(title: String(localized: "screen.defense.resolve", defaultValue: "Résoudre l’assaut"), systemImage: "shield.fill")
                            }
                            .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                            .buttonBorderShape(.roundedRectangle(radius: 14))
                            .accessibilityIdentifier("defense.resolve")
                            Button {
                                confirmsAssault = false
                            } label: {
                                AdaptiveActionLabel(title: String(localized: "screen.defense.cancel", defaultValue: "Continuer les préparatifs"), systemImage: "arrow.uturn.backward")
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle(radius: 14))
                            .accessibilityIdentifier("defense.cancel")
                        } else {
                            Button {
                                if campaign.tidesUntilAssault == 1 && !session.state.isUnderProtection() { confirmsAssault = true }
                                else { session.advanceCoastalTide() }
                            } label: {
                                AdaptiveActionLabel(title: campaign.tidesUntilAssault == 1 && !session.state.isUnderProtection()
                                      ? String(localized: "screen.defense.advance_and_defend", defaultValue: "Passer la marée et défendre")
                                      : String(localized: "screen.defense.advance", defaultValue: "Passer la marée"), systemImage: "water.waves")
                            }
                            .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                            .buttonBorderShape(.roundedRectangle(radius: 14))
                            .disabled(campaign.tide >= 1_000_000)
                            .accessibilityIdentifier("defense.advance")
                        }
                    } else {
                        Button {
                            session.startCoastalCampaign()
                        } label: {
                            AdaptiveActionLabel(title: String(localized: "screen.defense.start", defaultValue: "Ouvrir la campagne côtière"), systemImage: "flag.fill")
                        }
                        .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                        .buttonBorderShape(.roundedRectangle(radius: 14))
                        .disabled(!session.state.canStartCoastalCampaign)
                        .accessibilityIdentifier("defense.start")
                        if !session.state.canStartCoastalCampaign {
                            Text(String(localized: "screen.defense.requirements", defaultValue: "Construisez la Cour des armes et recrutez au moins une unité au village pour commencer."))
                                .font(.footnote)
                        }
                    }
                }
                .tint(Palette.amber).listRowBackground(Palette.panel)
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
