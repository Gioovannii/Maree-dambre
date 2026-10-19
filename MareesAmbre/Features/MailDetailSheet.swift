import SwiftUI

struct MailDetailSheet: View {
    let mail: GameMail
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Label(mail.content.title, systemImage: mail.content.symbol)
                        .font(.title2.bold()).fontDesign(.serif).foregroundStyle(mail.content.tint)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(session.settlementName(at: mail.village)).font(.headline)
                        if mail.imported == true {
                            Text(String(localized: "mail.imported", defaultValue: "Rapport antérieur"))
                                .font(.caption).foregroundStyle(Palette.muted)
                        } else {
                            Text(mail.createdAt, format: .dateTime.day().month().year().hour().minute())
                                .font(.caption).foregroundStyle(Palette.muted)
                        }
                    }
                    content
                }
                .padding(20).frame(maxWidth: 650, alignment: .leading).frame(maxWidth: .infinity)
            }
            .background(Palette.ocean).foregroundStyle(Palette.paper)
            .navigationTitle(String(localized: "mail.title", defaultValue: "Messagerie"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "expansion.close", defaultValue: "Fermer")) { dismiss() }
                }
            }
        }
        .tint(Palette.amber).preferredColorScheme(.dark)
        .presentationDetents([.large]).presentationDragIndicator(.visible)
    }
    @ViewBuilder private var content: some View {
        switch mail.content {
        case .welcome:
            Text(String(localized: "mail.welcome.body", defaultValue: "Bienvenue dans l’archipel. Développez vos ressources, préparez votre défense et explorez les rivages pour choisir votre prochaine implantation. Retrouvez ici les nouvelles du domaine, les rapports de combat et les livraisons de vos villages."))
                .font(.body).fixedSize(horizontal: false, vertical: true)
        case .protectionStarted(let end), .protectionExtended(let end):
            Text(String(localized: "protection.mail.body", defaultValue: "Cette protection couvre tous vos villages. Vos raids et vos transports restent disponibles. Les attaques contre vos villages sont suspendues jusqu’à l’échéance indiquée."))
            Text(end, format: .dateTime.day().month().year().hour().minute()).font(.headline)
        case .protectionEnded:
            Text(String(localized: "protection.mail.expired_body", defaultValue: "La protection initiale de votre domaine est terminée. Préparez vos garnisons. Les implantations fondées dans un refuge restent protégées par leur emplacement."))
        case .raid(let report): RaidReportView(report: report)
        case .defense(let report):
            DefenseReportView(report: report)
            ShipmentCargoSummary(resources: report.stolen)
        case .commerce(let report): ConvoyReportView(report: report)
        case .colony(let voyage):
            Label(voyage.role.name, systemImage: voyage.role.symbol).font(.headline)
            Text("\(voyage.destination.x), \(voyage.destination.y)")
            Text(voyage.role.benefit)
            if voyage.isRefuge {
                Label(String(localized: "expansion.refuge", defaultValue: "Refuge : aucune attaque subie dans cette colonie"), systemImage: "shield.fill")
            }
            Text(String(localized: "mail.colony.body", defaultValue: "Les colons sont installés. L’escorte reste en garnison ; votre nouvelle implantation est disponible dans le sélecteur de villages et sur la carte."))
        case .shipment(let order):
            Text(String(localized: "mail.shipment.body", defaultValue: "La cargaison a été entièrement déchargée à destination."))
            Text("\(order.destination.x), \(order.destination.y)")
            ShipmentCargoSummary(resources: order.cargo)
            Text(String(localized: "mail.shipment.return", defaultValue: "Retour prévu de l’escorte"))
                .font(.headline)
            Text(order.returnsAt, format: .dateTime.day().month().hour().minute())
        }
    }
}
