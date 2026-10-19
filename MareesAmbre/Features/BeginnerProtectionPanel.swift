import SwiftUI

struct BeginnerProtectionPanel: View {
    @Environment(VillageSession.self) private var session
    @State private var confirmsExtension = false

    var body: some View {
        if let protection = session.state.beginnerProtection {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                let now = ProcessInfo.processInfo.arguments.contains("--ui-snapshot") ? protection.startedAt : timeline.date
                VStack(alignment: .leading, spacing: 12) {
                    Label(protection.isActive(at: now)
                          ? String(localized: "protection.active", defaultValue: "Protection initiale active")
                          : String(localized: "protection.expired", defaultValue: "Protection initiale terminée"), systemImage: "shield.lefthalf.filled")
                        .font(.headline).foregroundStyle(Palette.amber)
                    if protection.isActive(at: now) {
                        Text(String(localized: "protection.scope", defaultValue: "Tous vos villages sont protégés. Les raids contre les voisins et les transports restent disponibles."))
                            .font(.subheadline)
                        LabeledContent(String(localized: "protection.remaining", defaultValue: "Temps restant"),
                                       value: GameProgression.durationText(max(0, protection.endsAt.timeIntervalSince(now))))
                            .font(.subheadline.bold()).monospacedDigit()
                        Text(protection.endsAt, format: .dateTime.day().month().hour().minute())
                            .font(.caption).foregroundStyle(Palette.muted)
                        if protection.canExtend(at: now) {
                            Button(String(localized: "protection.extend", defaultValue: "Prolonger de 48 h"), systemImage: "shield.badge.plus") { confirmsExtension = true }
                                .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                                .accessibilityIdentifier("protection.extend")
                                .confirmationDialog(String(localized: "protection.confirm", defaultValue: "Utiliser votre unique prolongation ? Les 48 heures s’ajoutent à la fin des 72 heures initiales."), isPresented: $confirmsExtension, titleVisibility: .visible) {
                                    Button(String(localized: "protection.extend", defaultValue: "Prolonger de 48 h"), action: session.extendProtection)
                                }
                            Text(String(localized: "protection.extension_rule", defaultValue: "Une seule prolongation, à activer avant la fin de la protection. Jusqu’à 120 heures au total."))
                                .font(.footnote).foregroundStyle(Palette.muted)
                        } else {
                            Text(String(localized: "protection.used", defaultValue: "Prolongation unique déjà utilisée."))
                                .font(.footnote).foregroundStyle(Palette.muted)
                        }
                    } else {
                        Text(String(localized: "protection.after", defaultValue: "Préparez vos garnisons. Vos refuges restent protégés par leur emplacement."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                }
                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.panel, in: .rect(cornerRadius: 18))
                .foregroundStyle(Palette.paper).tint(Palette.amber)
            }
        }
    }
}
