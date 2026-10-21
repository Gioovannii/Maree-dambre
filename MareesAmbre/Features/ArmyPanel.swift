import SwiftUI

struct ArmyPanel: View {
    var isTraining = false
    @Environment(VillageSession.self) private var session
    @State private var count = 1
    @State private var target: BotFaction?
    @State private var reportDestination: RaidReportDestination?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isTraining ? String(localized: "screen.army.training", defaultValue: "Entraînement") : String(localized: "screen.army.troops_and_expeditions", defaultValue: "Troupes et expéditions")).font(.title2.bold())
            Text(isTraining ? String(localized: "screen.army.unlock_units_at_the_academy_capacity_100_units", defaultValue: "Débloquez vos unités à la Maison des savoirs. Capacité : 100 unités.") : String(localized: "screen.army.train_units_at_the_training_grounds_in_town_neighboring_factions_are_simulated_offlin", defaultValue: "Entraînez vos unités à la Cour des armes, dans le Centre. Les factions voisines sont gérées par le jeu hors ligne."))
                .font(.footnote).foregroundStyle(Palette.muted)
            if isTraining {
            Stepper(String(localized: "screen.army.recruit", defaultValue: "Recruter : \(String(count))"), value: $count, in: 1...20)
            ForEach(session.state.trainableUnits) { unit in
                VStack(alignment: .leading, spacing: 8) {
                    Image(unit.imageAssetName).resizable().scaledToFit()
                        .frame(height: 120).clipShape(.rect(cornerRadius: 12))
                        .accessibilityHidden(true)
                    Label(String(localized: "screen.army.available_units", defaultValue: "\(String(unit.name)) · \(String(session.state.availableArmy[unit, default: 0])) disponible(s)"), systemImage: unit.emblem)
                        .font(.headline)
                    ArmyUnitStatsView(unit: unit)
                    if !session.state.unlockedUnits.contains(unit) {
                        Label(String(localized: "screen.army.unlock_at_the_academy", defaultValue: "À débloquer à la Maison des savoirs"), systemImage: "lock.fill")
                    }
                    Text(String(localized: "screen.army.training_cost", defaultValue: "Coût : \(String(unit.cost.wood * count)) bois · \(String(unit.cost.amber * count)) ambre · \(String(unit.cost.provisions * count)) vivres"))
                    Button(String(localized: "progression.training.action", defaultValue: "Entraîner · \(String(GameProgression.durationText(ceil(Double(count) * session.state.trainingSecondsPerUnit))))")) { session.train(unit, count: count) }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(Palette.ocean)
                        .disabled(!session.state.canTrain(unit, count: count))
                        .modifier(GuidedActionModifier(step: .train, isTarget: unit == session.state.trainableUnits.first(where: { session.state.unlockedUnits.contains($0) })))
                }
                .id(unit == session.state.trainableUnits.first(where: { session.state.unlockedUnits.contains($0) }) ? "guide.action" : unit.rawValue)
                .font(.subheadline).padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.panel, in: .rect(cornerRadius: 14))
            }
            if let training = session.state.army?.training {
                Label(String(localized: "screen.army_panel.value", defaultValue: "\(String(training.count)) × \(String(training.unit.name))"), systemImage: "hourglass")
                countdown(training.endsAt)
            }
            }
            if !isTraining {
            if let report = session.state.army?.raidReport {
                Text(String(localized: "screen.army.latest_report", defaultValue: "Dernier rapport")).font(.headline)
                Button {
                    reportDestination = RaidReportDestination(report: report)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: report.won ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            .font(.title2).foregroundStyle(report.won ? Color.mint : Color.orange)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(report.targetName).font(.headline).foregroundStyle(Palette.paper)
                            Text(report.won ? String(localized: "screen.raid_report.victory", defaultValue: "Victoire")
                                 : String(localized: "screen.raid_report.defeat", defaultValue: "Défaite"))
                                .font(.subheadline.bold()).foregroundStyle(report.won ? Color.mint : Color.orange)
                            Label(String(localized: "battle.report.open", defaultValue: "Ouvrir le rapport"), systemImage: "doc.text.magnifyingglass")
                                .font(.caption.bold()).foregroundStyle(Palette.amber)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").foregroundStyle(Palette.amber)
                    }
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.panel, in: .rect(cornerRadius: 18))
                    .overlay { RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.amber.opacity(0.4)) }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("raid.openReport")
            } else if let report = session.state.army?.report {
                Text(String(localized: "screen.army.latest_report", defaultValue: "Dernier rapport")).font(.headline)
                Text(report).font(.subheadline)
            }
            if let convoy = session.state.army?.convoy {
                Text(String(localized: "screen.commerce.active", defaultValue: "\(String(convoy.units.values.reduce(0, +))) unités en escorte · Retour à la marée \(String(convoy.returnsAtTide))"))
            }
            if let raid = session.state.army?.raid {
                Text(String(localized: "screen.army.expedition_to_value_returning", defaultValue: "Expédition vers \(String(raid.targetDisplayName)) · Retour"))
                countdown(raid.returnsAt)
                Text(String(localized: "screen.army.deployed_count", defaultValue: "Unités en expédition : \(String(raid.units.values.reduce(0, +)))"))
            }
            Text(String(localized: "screen.army.garrison_count", defaultValue: "Unités au village : \(String(session.state.availableArmy.values.reduce(0, +)))"))
                .accessibilityIdentifier("raid.garrisonCount")
            Text(String(localized: "screen.army.available_power_value", defaultValue: "Force disponible : \(String(session.state.armyPower))")).font(.headline)
            Text(String(localized: "screen.army.expedition_rules", defaultValue: "Choisissez les troupes envoyées et celles qui restent au village. Les cibles lointaines demandent plus de temps. Une cible se repose 10 minutes après le retour."))
                .font(.footnote).foregroundStyle(Palette.muted)
            ForEach(session.state.bots) { bot in
                VStack(alignment: .leading, spacing: 6) {
                    Text(WorldNeighbor.name(for: bot, seed: session.world.seed)).font(.headline)
                    Text(String(localized: "world.neighbor.tribe", defaultValue: "\(String(bot.displayName)) · Voisin simulé (IA)"))
                        .font(.caption).foregroundStyle(Palette.muted)
                    Text(String(localized: "screen.army.defense_value", defaultValue: "Défense : \(String(bot.defensePower))"))
                    Text(String(localized: "screen.army.target_distance_and_roundtrip", defaultValue: "Niveau \(String(bot.level)) · Distance : \(String(bot.distanceFromHome)) cases · Aller-retour : \(String(Int(session.state.raidDuration(to: bot)))) s"))
                        .font(.caption).foregroundStyle(Palette.muted)
                    Button(String(localized: "screen.army.prepare_attack", defaultValue: "Préparer l’attaque")) { target = bot }
                        .buttonStyle(.bordered)
                        .disabled(!session.state.canRaid(bot))
                        .accessibilityIdentifier("raid.prepare.\(bot.id)")
                        .modifier(GuidedActionModifier(step: .raid, isTarget: bot.id == session.state.bots.first?.id, anchor: "prepare"))
                    if let until = session.state.army?.raidedUntil[bot.id], until > Date.now {
                        Text(String(localized: "screen.army.target_available_at_value", defaultValue: "Cible disponible à \(String(until.formatted(date: .omitted, time: .shortened)))")).font(.caption)
                    }
                }
            }

            }
        }
        .tint(Palette.amber)
        .task {
            while !Task.isCancelled {
                session.refreshWorld()
                do { try await Task.sleep(for: .seconds(1)) } catch { return }
            }
        }
        .onAppear {
            if !isTraining, ProcessInfo.processInfo.arguments.contains("--snapshot-raid-preparation") {
                target = session.state.bots.first
            }
            if !isTraining, ProcessInfo.processInfo.arguments.contains("--snapshot-raid-report"),
               let report = session.state.army?.raidReport {
                var snapshotTransaction = Transaction(animation: nil)
                snapshotTransaction.disablesAnimations = true
                withTransaction(snapshotTransaction) {
                    reportDestination = RaidReportDestination(report: report)
                }
            }
        }
        .sheet(item: $reportDestination) { destination in
            RaidReportSheet(report: destination.report)
        }
        .sheet(item: $target) { bot in
            RaidPreparationView(target: bot)
        }
    }

    private func countdown(_ end: Date) -> some View {
        Text(timerInterval: min(Date.now, end)...end, countsDown: true)
            .monospacedDigit().foregroundStyle(Palette.amber)
    }
}
