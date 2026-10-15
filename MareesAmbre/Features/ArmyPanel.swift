import SwiftUI

struct ArmyPanel: View {
    var isTraining = false
    @Environment(VillageSession.self) private var session
    @State private var count = 1
    @State private var target: BotFaction?

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
                    Text(String(localized: "screen.army.power_value_carries_value_resources", defaultValue: "Force \(String(session.state.attackStrength(of: unit))) · Transport \(String(unit.carrying)) ressources"))
                    Text(String(localized: "screen.army.unit_defense", defaultValue: "Défense du port : \(String(unit.defense + session.state.weaponLevel)) par unité"))
                    if !session.state.unlockedUnits.contains(unit) {
                        Label(String(localized: "screen.army.unlock_at_the_academy", defaultValue: "À débloquer à la Maison des savoirs"), systemImage: "lock.fill")
                    }
                    Text(String(localized: "screen.army.training_cost", defaultValue: "Coût : \(String(unit.cost.wood * count)) bois · \(String(unit.cost.amber * count)) ambre · \(String(unit.cost.provisions * count)) vivres"))
                    Button(String(localized: "screen.army.train", defaultValue: "Entraîner · \(String(count * 30)) s")) { session.train(unit, count: count) }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(Palette.ocean)
                        .disabled(!session.state.canTrain(unit, count: count))
                }
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
            Text(String(localized: "screen.army.expedition_rules", defaultValue: "Choisissez les troupes envoyées et celles qui restent au village. Aller-retour : \(String(Int(session.state.raidDuration))) secondes. Une cible se repose 10 minutes après le retour."))
                .font(.footnote).foregroundStyle(Palette.muted)
            ForEach(session.state.bots) { bot in
                VStack(alignment: .leading, spacing: 6) {
                    Text(bot.displayName).font(.headline)
                    Text(String(localized: "screen.army.defense_value", defaultValue: "Défense : \(String(10 + min(10, bot.level) * 4))"))
                    Button(String(localized: "screen.army.prepare_attack", defaultValue: "Préparer l’attaque")) { target = bot }
                        .buttonStyle(.bordered)
                        .disabled(!session.state.canRaid(bot))
                        .accessibilityIdentifier("raid.prepare.\(bot.id)")
                    if let until = session.state.army?.raidedUntil[bot.id], until > Date.now {
                        Text(String(localized: "screen.army.target_available_at_value", defaultValue: "Cible disponible à \(String(until.formatted(date: .omitted, time: .shortened)))")).font(.caption)
                    }
                }
            }
            if let report = session.state.army?.report {
                Text(String(localized: "screen.army.latest_report", defaultValue: "Dernier rapport")).font(.headline)
                Text(report).font(.subheadline)
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
        .sheet(item: $target) { bot in
            RaidPreparationView(target: bot)
        }
    }

    private func countdown(_ end: Date) -> some View {
        Text(timerInterval: min(Date.now, end)...end, countsDown: true)
            .monospacedDigit().foregroundStyle(Palette.amber)
    }
}
