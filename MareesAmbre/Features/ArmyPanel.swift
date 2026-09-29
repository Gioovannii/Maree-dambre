import SwiftUI

struct ArmyPanel: View {
    var isTraining = false
    @Environment(VillageSession.self) private var session
    @State private var count = 1
    @State private var target: BotFaction?
    @State private var confirmsRaid = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isTraining ? "Entraînement" : "Troupes et expéditions").font(.title2.bold())
            Text(isTraining ? "Débloquez vos unités à la Maison des savoirs. Capacité : 100 unités." : "Entraînez vos unités à la Cour des armes, dans le Centre. Les factions voisines sont gérées par le jeu hors ligne.")
                .font(.footnote).foregroundStyle(Palette.muted)
            if isTraining {
            Stepper("Recruter : \(count)", value: $count, in: 1...20)
            ForEach(ArmyUnit.allCases) { unit in
                VStack(alignment: .leading, spacing: 8) {
                    Label("\(unit.name) · \(session.state.availableArmy[unit, default: 0]) disponible(s)", systemImage: unit.emblem)
                        .font(.headline)
                    Text("Force \(unit.attack) · Transport \(unit.carrying) ressources")
                    if !session.state.unlockedUnits.contains(unit) {
                        Label("À débloquer à la Maison des savoirs", systemImage: "lock.fill")
                    }
                    Text("Coût : \(unit.cost.wood * count) bois · \(unit.cost.amber * count) ambre · \(unit.cost.provisions * count) vivres")
                    Button("Entraîner · \(count * 30) s") { session.train(unit, count: count) }
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
                Text("Expédition vers \(raid.targetName) · Retour")
                countdown(raid.returnsAt)
            }
            Text("Force disponible : \(session.state.armyPower)").font(.headline)
            Text("Chaque départ mobilise toutes les troupes disponibles. Aller-retour : 2 minutes. Une cible se repose 10 minutes après le retour.")
                .font(.footnote).foregroundStyle(Palette.muted)
            ForEach(session.state.bots) { bot in
                VStack(alignment: .leading, spacing: 6) {
                    Text(bot.name).font(.headline)
                    Text("Défense : \(10 + min(10, bot.level) * 4)")
                    Button("Préparer l’attaque") { target = bot; confirmsRaid = true }
                        .buttonStyle(.bordered)
                        .disabled(!session.state.canRaid(bot))
                    if let until = session.state.army?.raidedUntil[bot.id], until > Date.now {
                        Text("Cible disponible à \(until.formatted(date: .omitted, time: .shortened))").font(.caption)
                    }
                }
            }
            if let report = session.state.army?.report {
                Text("Dernier rapport").font(.headline)
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
        .confirmationDialog("Départ vers \(target?.name ?? "")", isPresented: $confirmsRaid, presenting: target) { bot in
            Button("Envoyer toutes les troupes") { session.raid(bot.id); target = nil }
        } message: { bot in
            Text(session.state.armyPower > 10 + min(10, bot.level) * 4
                 ? "Victoire prévue. Pertes : 20 % arrondies à l’entier inférieur par type. Butin : jusqu’à 60 de chaque ressource, selon le transport des survivants et la place en réserve."
                 : "Défaite prévue : la moitié des troupes sera perdue, arrondie au supérieur par type. Aucun butin.")
        }
    }

    private func countdown(_ end: Date) -> some View {
        Text(timerInterval: min(Date.now, end)...end, countsDown: true)
            .monospacedDigit().foregroundStyle(Palette.amber)
    }
}
