import SwiftUI

struct ResearchPanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Doctrines militaires").font(.title2.bold())
            Text("Chaque recherche débloque définitivement une unité pour ce village. Entraînez-la ensuite à la Cour des armes.")
                .font(.subheadline).foregroundStyle(Palette.muted)
            if let research = session.state.army?.research {
                Label(research.unit.name, systemImage: "hourglass")
                Text(timerInterval: min(Date.now, research.endsAt)...research.endsAt, countsDown: true)
                    .monospacedDigit()
            }
            ForEach(ArmyUnit.allCases) { unit in
                VStack(alignment: .leading, spacing: 8) {
                    Label(unit.name, systemImage: unit.emblem).font(.headline)
                    Text("Force \(unit.attack) · Transport \(unit.carrying)").font(.subheadline)
                    if session.state.unlockedUnits.contains(unit) {
                        Label("Doctrine acquise", systemImage: "checkmark.seal.fill")
                    } else {
                        Text("\(unit.researchCost.wood) bois · \(unit.researchCost.amber) ambre · \(unit.researchCost.provisions) vivres")
                            .font(.footnote)
                        Button("Rechercher · 1 min") { session.research(unit) }
                            .buttonStyle(.borderedProminent)
                            .disabled(!session.state.canResearch(unit))
                    }
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.ocean, in: .rect(cornerRadius: 14))
            }
        }
        .tint(Palette.amber)
        .task {
            while !Task.isCancelled {
                session.refreshWorld()
                do { try await Task.sleep(for: .seconds(1)) } catch { return }
            }
        }
    }
}
