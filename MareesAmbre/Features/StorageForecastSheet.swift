import SwiftUI

struct StorageForecastSheet: View {
    @Environment(\.dismiss) private var dismiss
    let resources: Resources
    let hourlyProduction: Resources
    let capacity: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(String(localized: "storage.forecast.intro", defaultValue: "Votre village continue de produire pendant votre absence. Voici quand chaque réserve devrait se remplir au rythme actuel."))
                        .foregroundStyle(Palette.muted)
                    ForEach(ResourceKind.allCases) { kind in
                        VStack(alignment: .leading, spacing: 10) {
                            Label(kind.name, systemImage: kind.symbol)
                                .font(.headline).foregroundStyle(Palette.amber)
                            Text("\(resources[kind].formatted()) / \(capacity.formatted())")
                                .font(.title3.bold()).monospacedDigit()
                            ProgressView(value: Double(min(resources[kind], capacity)), total: Double(max(1, capacity)))
                                .tint(Palette.amber)
                                .accessibilityLabel(kind.name)
                            Text(status(for: kind))
                                .font(.subheadline.bold())
                            Text(String(localized: "storage.forecast.rate", defaultValue: "Production : \(String(hourlyProduction[kind])) par heure"))
                                .font(.footnote).foregroundStyle(Palette.muted)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Palette.panel, in: .rect(cornerRadius: 20))
                    }
                    Label(String(localized: "storage.forecast.help", defaultValue: "Une réserve pleine ne perd pas son stock : seule la nouvelle production de cette ressource s’arrête. Dépensez vos ressources ou améliorez l’Entrepôt au Centre pour retrouver de la place."), systemImage: "shippingbox.fill")
                        .font(.footnote).foregroundStyle(Palette.muted)
                    Text(String(localized: "storage.forecast.estimate", defaultValue: "Estimation arrondie à la minute, hors futurs chantiers, dépenses, butins et livraisons. Chaque village possède ses propres réserves."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .padding(20)
            }
            .background(Palette.ocean)
            .foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "storage.forecast.title", defaultValue: "Mes réserves"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "storage.forecast.close", defaultValue: "Fermer")) { dismiss() }
                }
            }
        }
    }

    private func status(for kind: ResourceKind) -> String {
        guard let seconds = StorageForecast.timeUntilFull(stock: resources[kind], capacity: capacity, hourlyRate: hourlyProduction[kind]) else {
            return String(localized: "storage.forecast.no_production", defaultValue: "Aucune production pour le moment")
        }
        guard seconds > 0 else {
            return String(localized: "storage.forecast.full", defaultValue: "Réserve pleine · production en pause")
        }
        let minutes = max(1, Int(ceil(seconds / 60)))
        let duration = Duration.seconds(minutes * 60).formatted(.units(allowed: [.days, .hours, .minutes], width: .abbreviated))
        return String(localized: "storage.forecast.remaining", defaultValue: "Pleine dans environ \(duration)")
    }
}
