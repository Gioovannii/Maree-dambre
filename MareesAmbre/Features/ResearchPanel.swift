import SwiftUI

struct ResearchPanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "screen.research.units_value", defaultValue: "Unités · \(String(session.state.people?.name ?? String(localized: "screen.research.humans", defaultValue: "Humains")))")).font(.title2.bold())
            Text(String(localized: "screen.research.each_research_permanently_unlocks_a_unit_for_this_village_train_it_at_the_training_gr", defaultValue: "Chaque recherche débloque définitivement une unité pour ce village. Entraînez-la ensuite à la Cour des armes."))
                .font(.subheadline).foregroundStyle(Palette.muted)
            if let research = session.state.army?.research {
                Label(research.unit.name, systemImage: "hourglass")
                Text(timerInterval: min(Date.now, research.endsAt)...research.endsAt, countsDown: true)
                    .monospacedDigit()
            }
            ForEach(session.state.peopleUnits) { unit in
                VStack(alignment: .leading, spacing: 8) {
                    Image(unit.imageAssetName)
                        .resizable().scaledToFit()
                        .frame(maxHeight: 240)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: 12))
                        .accessibilityHidden(true)
                    Label(unit.name, systemImage: unit.emblem).font(.headline)
                    Text(unit.role).font(.subheadline.bold()).foregroundStyle(Palette.amber)
                    Text(unit.description).font(.subheadline).foregroundStyle(Palette.muted)
                    Text(String(localized: "screen.research.power_value_carrying_capacity_value", defaultValue: "Force \(String(unit.attack)) · Transport \(String(unit.carrying))")).font(.subheadline)
                    if session.state.unlockedUnits.contains(unit) {
                        Label(String(localized: "screen.research.doctrine_learned", defaultValue: "Doctrine acquise"), systemImage: "checkmark.seal.fill")
                    } else {
                        Text(String(localized: "screen.research.value_wood_value_amber_value_food", defaultValue: "\(String(unit.researchCost.wood)) bois · \(String(unit.researchCost.amber)) ambre · \(String(unit.researchCost.provisions)) vivres"))
                            .font(.footnote)
                        Button(String(localized: "screen.research.research_1_min", defaultValue: "Rechercher · 1 min")) { session.research(unit) }
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
