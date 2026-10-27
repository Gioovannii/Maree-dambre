import SwiftUI

struct LighthousePanel: View {
    @Environment(VillageSession.self) private var session
    @State private var confirmsStart = false
    private var progress: LighthouseProgress { session.state.lighthouseProgress }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "lighthouse.title", defaultValue: "Le Grand Phare"), systemImage: progress.isComplete ? "sun.max.fill" : "light.beacon.max.fill")
                .font(.headline).foregroundStyle(Palette.amber)
            if progress.isComplete {
                Text(String(localized: "lighthouse.victory", defaultValue: "Le Grand Phare brille à nouveau. Campagne accomplie !"))
                    .font(.title3.bold()).fontDesign(.serif)
                Text(String(localized: "lighthouse.after", defaultValue: "Les raids automatiques cessent. Votre domaine reste jouable : développez vos villages et poursuivez vos expéditions à votre rythme."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
                if let date = progress.completedAt { Text(date, format: .dateTime.day().month().year()).font(.caption) }
            } else if session.state.settlementCount < VillageState.maximumSettlements {
                Text(String(localized: "lighthouse.unlock", defaultValue: "Fondez trois villages pour reconstruire le Grand Phare et rouvrir les routes de l’archipel. Cinq chantiers vous mèneront à son allumage."))
                    .font(.subheadline).foregroundStyle(Palette.muted)
            } else if let stage = progress.stage {
                Text(stage.title).font(.title3.bold())
                ProgressView(value: Double(progress.completedStages), total: Double(LighthouseStage.allCases.count))
                    .accessibilityLabel(String(localized: "lighthouse.progress", defaultValue: "Reconstruction du Grand Phare"))
                if let start = progress.startedAt, let end = progress.finishesAt {
                    ProgressView(timerInterval: start...end, countsDown: false)
                        .accessibilityLabel(stage.title)
                    Text(end, style: .timer).monospacedDigit()
                    Text(String(localized: "lighthouse.running", defaultValue: "Les travaux continuent pendant votre absence. L’étape suivante attendra votre décision."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                } else if session.state.location != .home {
                    Text(String(localized: "lighthouse.capital", defaultValue: "Les ressources du chantier sont prises dans la capitale. Les convois de vos colonies permettent d’y réunir les matériaux."))
                        .font(.subheadline).foregroundStyle(Palette.muted)
                    Button(String(localized: "expansion.return_capital", defaultValue: "Gérer la capitale")) { session.switchSettlement(to: .home) }
                        .buttonStyle(.bordered)
                } else {
                    ExpansionCostView(cost: stage.cost)
                    Text(GameProgression.durationText(stage.duration)).font(.caption)
                    Text(String(localized: "lighthouse.capital", defaultValue: "Les ressources du chantier sont prises dans la capitale. Les convois de vos colonies permettent d’y réunir les matériaux."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                    if session.state.storageCapacity < max(stage.cost.wood, stage.cost.amber, stage.cost.provisions) {
                        Label(String(localized: "lighthouse.storage", defaultValue: "Améliorez l’entrepôt pour contenir le coût de cette étape."), systemImage: "shippingbox")
                            .font(.footnote)
                    }
                    Button(String(localized: "lighthouse.begin", defaultValue: "Lancer cette étape"), systemImage: "hammer.fill") { confirmsStart = true }
                        .buttonStyle(.borderedProminent)
                        .disabled(!session.state.canStartLighthouseStage)
                }
                DisclosureGroup(String(localized: "lighthouse.plan", defaultValue: "Les cinq chantiers")) {
                    ForEach(LighthouseStage.allCases, id: \.rawValue) { item in
                        Label(item.title, systemImage: item.rawValue < progress.completedStages ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline).padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 20))
        .confirmationDialog(String(localized: "lighthouse.confirm", defaultValue: "Engager les ressources de la capitale ? Le chantier ne peut pas être annulé."), isPresented: $confirmsStart, titleVisibility: .visible) {
            Button(String(localized: "lighthouse.begin", defaultValue: "Lancer cette étape"), action: session.startLighthouseStage)
        }
    }
}
