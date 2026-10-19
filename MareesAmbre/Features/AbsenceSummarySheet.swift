import SwiftUI

struct AbsenceSummarySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    let summary: AbsenceSummary
    let onShowMessages: () -> Void

    private var stockLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    let elapsed = Duration.seconds(Int(summary.until.timeIntervalSince(summary.from))).formatted(.units(allowed: [.days, .hours, .minutes], width: .abbreviated))
                    Text(String(localized: "absence.duration", defaultValue: "Votre domaine a continué de vivre pendant environ \(elapsed)."))
                        .foregroundStyle(Palette.muted)
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "absence.stocks", defaultValue: "Évolution des stocks du domaine"), systemImage: "shippingbox.fill")
                            .font(.headline).foregroundStyle(Palette.amber)
                        ForEach(ResourceKind.allCases) { kind in
                            stockLayout {
                                Label(kind.name, systemImage: kind.symbol)
                                if !typeSize.isAccessibilitySize { Spacer() }
                                Text(summary.stockChange[kind].formatted(.number.sign(strategy: .always())))
                                    .bold().monospacedDigit()
                            }
                            .accessibilityElement(children: .combine)
                        }
                        Text(String(localized: "absence.net_help", defaultValue: "Variation nette des réserves de tous vos villages : production conservée, butins, livraisons, fondations et pillages compris. Ce n’est pas la production totale."))
                            .font(.footnote).foregroundStyle(Palette.muted)
                    }
                    .padding(18)
                    .background(Palette.panel, in: .rect(cornerRadius: 20))
                    VStack(alignment: .leading, spacing: 14) {
                        Label(String(localized: "absence.work", defaultValue: "Travaux et recherches terminés : \(String(summary.completedWork))"), systemImage: "hammer.fill")
                        Label(String(localized: "absence.training", defaultValue: "Recrues formées : \(String(summary.trainedUnits))"), systemImage: "person.2.fill")
                        if summary.newVillages > 0 {
                            Label(String(localized: "absence.villages", defaultValue: "Nouveaux villages : \(String(summary.newVillages))"), systemImage: "house.and.flag.fill")
                        }
                        if summary.fullStores > 0 {
                            Label(String(localized: "absence.full", defaultValue: "Réserves pleines : \(String(summary.fullStores)). Vous pouvez libérer de la place à votre rythme."), systemImage: "shippingbox.and.arrow.backward.fill")
                                .foregroundStyle(Palette.amber)
                        }
                    }
                    .font(.subheadline)
                    if summary.reports.isEmpty {
                        Label(String(localized: "absence.quiet", defaultValue: "Aucun nouveau rapport de mission ou de combat."), systemImage: "checkmark.shield.fill")
                            .foregroundStyle(Palette.muted)
                    } else {
                        Text(String(localized: "absence.reports", defaultValue: "Nouveaux rapports : \(String(summary.reports.count))"))
                            .font(.headline)
                        ForEach(summary.reports.prefix(3)) { mail in
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mail.content.title).bold()
                                    Text(mail.content.summary).foregroundStyle(Palette.muted)
                                }
                            } icon: {
                                Image(systemName: mail.content.symbol).foregroundStyle(mail.content.tint)
                            }
                        }
                        Button(String(localized: "absence.messages", defaultValue: "Ouvrir les rapports dans Messages"), systemImage: "envelope.fill", action: onShowMessages)
                            .buttonStyle(.borderedProminent).tint(Palette.amber).foregroundStyle(Palette.ocean)
                    }
                    Text(String(localized: "absence.saved", defaultValue: "Les rapports restent disponibles dans Messages après la fermeture de ce bilan."))
                        .font(.footnote).foregroundStyle(Palette.muted)
                }
                .padding(20)
            }
            .foregroundStyle(Palette.paper)
            .background(Palette.ocean)
            .navigationTitle(String(localized: "absence.title", defaultValue: "Pendant votre absence"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "absence.close", defaultValue: "Reprendre")) { dismiss() }
                }
            }
        }
    }
}
