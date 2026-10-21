import SwiftUI

struct ReconnaissancePanel: View {
    let target: BotFaction
    @Environment(VillageSession.self) private var session
    @State private var detail: ReconnaissanceDetail = .standard

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let report = session.state.army?.reconnaissance?[target.id]
            let current = report?.isCurrent(for: target, at: timeline.date) ?? false
            let alreadyKnown = current && (report?.effectiveDetail == .detailed || detail == .standard)
            VStack(alignment: .leading, spacing: 8) {
                Label(String(localized: "recon.title", defaultValue: "Reconnaissance"), systemImage: "binoculars")
                    .font(.headline)
                Picker(String(localized: "recon.mode", defaultValue: "Niveau de reconnaissance"), selection: $detail) {
                    ForEach(ReconnaissanceDetail.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                Text(detail == .standard
                     ? String(localized: "recon.normal_help", defaultValue: "Effectif total observé. Académie niveau 1 requise.")
                     : String(localized: "recon.advanced_help", defaultValue: "Effectifs par type, caractéristiques de combat et fortifications. Académie niveau 3 requise."))
                    .font(.footnote).foregroundStyle(Palette.muted)
                if let report {
                    Text(report.effectiveDetail.title).font(.caption.bold())
                    Text(report.observedAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption).foregroundStyle(Palette.muted)
                    LabeledContent(String(localized: "recon.total", defaultValue: "Effectif observé"), value: report.units.values.reduce(0, +).formatted())
                    if report.effectiveDetail == .detailed {
                        ForEach(ArmyUnit.allCases.filter { report.units[$0, default: 0] > 0 }) { unit in
                            VStack(alignment: .leading, spacing: 4) {
                                LabeledContent(unit.name, value: report.units[unit, default: 0].formatted())
                                Text(String(localized: "recon.unit_stats", defaultValue: "Par unité : attaque \(String(unit.attack)) · défense \(String(unit.defense))"))
                                    .font(.caption).foregroundStyle(Palette.muted)
                            }
                        }
                        Text(String(localized: "recon.fortifications", defaultValue: "Fortifications : \(String(report.fortifications)) points de défense"))
                    }
                    if !current {
                        Text(String(localized: "recon.stale", defaultValue: "Renseignement ancien : les effectifs peuvent avoir changé. Actualisez avant de vous y fier."))
                            .foregroundStyle(Palette.amber)
                    }
                }
                Text(String(localized: "recon.rules", defaultValue: "Observation immédiate depuis les routes, sans envoyer de soldats. Académie requise. Le renseignement reste récent pendant dix minutes."))
                    .font(.footnote).foregroundStyle(Palette.muted)
                Button {
                    session.observeNeighbor(target.id, detail: detail)
                } label: {
                    Text(String(localized: "recon.observe", defaultValue: "Observer · \(String(session.state.reconnaissanceCost(for: detail))) vivres"))
                }
                .buttonStyle(.bordered)
                .disabled(alreadyKnown || session.state.buildingLevel(.academy) < detail.requiredAcademy || session.state.resources.provisions < session.state.reconnaissanceCost(for: detail))
            }
        }
    }
}
