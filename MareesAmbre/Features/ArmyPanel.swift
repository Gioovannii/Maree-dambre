import SwiftUI

struct ArmyPanel: View {
    var isTraining = false
    @Environment(VillageSession.self) private var session
    @State private var count = 1
    @State private var target: BotFaction?
    @State private var confirmsRaid = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isTraining ? L10n.text("Entraînement", "Training") : L10n.text("Troupes et expéditions", "Troops and expeditions")).font(.title2.bold())
            Text(isTraining ? L10n.text("Débloquez vos unités à la Maison des savoirs. Capacité : 100 unités.", "Unlock units at the Academy. Capacity: 100 units.") : L10n.text("Entraînez vos unités à la Cour des armes, dans le Centre. Les factions voisines sont gérées par le jeu hors ligne.", "Train units at the Training Grounds in town. Neighboring factions are simulated offline."))
                .font(.footnote).foregroundStyle(Palette.muted)
            if isTraining {
            Stepper(L10n.text("Recruter : \(count)", "Recruit: \(count)"), value: $count, in: 1...20)
            ForEach(session.state.trainableUnits) { unit in
                VStack(alignment: .leading, spacing: 8) {
                    Image(unit.imageAssetName).resizable().scaledToFit()
                        .frame(height: 120).clipShape(.rect(cornerRadius: 12))
                        .accessibilityHidden(true)
                    Label(L10n.text("\(unit.name) · \(session.state.availableArmy[unit, default: 0]) disponible(s)", "\(unit.name) · \(session.state.availableArmy[unit, default: 0]) available"), systemImage: unit.emblem)
                        .font(.headline)
                    Text(L10n.text("Force \(unit.attack) · Transport \(unit.carrying) ressources", "Power \(unit.attack) · Carries \(unit.carrying) resources"))
                    if !session.state.unlockedUnits.contains(unit) {
                        Label(L10n.text("À débloquer à la Maison des savoirs", "Unlock at the Academy"), systemImage: "lock.fill")
                    }
                    Text(L10n.text("Coût : \(unit.cost.wood * count) bois · \(unit.cost.amber * count) ambre · \(unit.cost.provisions * count) vivres", "Cost: \(unit.cost.wood * count) wood · \(unit.cost.amber * count) amber · \(unit.cost.provisions * count) food"))
                    Button(L10n.text("Entraîner · \(count * 30) s", "Train · \(count * 30) s")) { session.train(unit, count: count) }
                        .buttonStyle(.borderedProminent)
                        .disabled(!session.state.canTrain(unit, count: count))
                }
                .font(.subheadline).padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.panel, in: .rect(cornerRadius: 14))
            }
            if let training = session.state.army?.training {
                Label("\(training.count) × \(training.unit.name)", systemImage: "hourglass")
                countdown(training.endsAt)
            }
            }
            if !isTraining {
            if let raid = session.state.army?.raid {
                Text(L10n.text("Expédition vers \(raid.targetDisplayName) · Retour", "Expedition to \(raid.targetDisplayName) · Returning"))
                countdown(raid.returnsAt)
            }
            Text(L10n.text("Force disponible : \(session.state.armyPower)", "Available power: \(session.state.armyPower)")).font(.headline)
            Text(L10n.text("Chaque départ mobilise toutes les troupes disponibles. Aller-retour : \(Int(session.state.raidDuration)) secondes. Une cible se repose 10 minutes après le retour.", "Each expedition deploys all available troops. Round trip: \(Int(session.state.raidDuration)) seconds. Targets recover for 10 minutes after your return."))
                .font(.footnote).foregroundStyle(Palette.muted)
            ForEach(session.state.bots) { bot in
                VStack(alignment: .leading, spacing: 6) {
                    Text(bot.displayName).font(.headline)
                    Text(L10n.text("Défense : \(10 + min(10, bot.level) * 4)", "Defense: \(10 + min(10, bot.level) * 4)"))
                    Button(L10n.text("Préparer l’attaque", "Prepare attack")) { target = bot; confirmsRaid = true }
                        .buttonStyle(.bordered)
                        .disabled(!session.state.canRaid(bot))
                    if let until = session.state.army?.raidedUntil[bot.id], until > Date.now {
                        Text(L10n.text("Cible disponible à \(until.formatted(date: .omitted, time: .shortened))", "Target available at \(until.formatted(date: .omitted, time: .shortened))")).font(.caption)
                    }
                }
            }
            if let report = session.state.army?.report {
                Text(L10n.text("Dernier rapport", "Latest report")).font(.headline)
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
        .confirmationDialog(L10n.text("Départ vers \(target?.displayName ?? "")", "Departure for \(target?.displayName ?? "")"), isPresented: $confirmsRaid, presenting: target) { bot in
            Button(L10n.text("Envoyer toutes les troupes", "Send all troops")) { session.raid(bot.id); target = nil }
        } message: { bot in
            Text(session.state.armyPower > 10 + min(10, bot.level) * 4
                 ? L10n.text("Victoire prévue. Pertes : \(Int(session.state.victoryLossRate * 100)) % arrondies à l’entier inférieur par type. Butin : jusqu’à 60 de chaque ressource, selon le transport des survivants et la place en réserve.", "Victory expected. Losses: \(Int(session.state.victoryLossRate * 100))%, rounded down per unit type. Loot: up to 60 of each resource, limited by surviving carriers and available storage.")
                 : L10n.text("Défaite prévue : la moitié des troupes sera perdue, arrondie au supérieur par type. Aucun butin.", "Defeat expected: half your troops will be lost, rounded up per unit type. No loot."))
        }
    }

    private func countdown(_ end: Date) -> some View {
        Text(timerInterval: min(Date.now, end)...end, countsDown: true)
            .monospacedDigit().foregroundStyle(Palette.amber)
    }
}
