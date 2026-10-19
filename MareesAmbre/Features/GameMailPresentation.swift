import SwiftUI

extension GameMailContent {
    var title: String {
        switch self {
        case .heroMission: String(localized: "hero.mission.completed", defaultValue: "Mission du héros terminée")
        case .welcome: String(localized: "mail.welcome.title", defaultValue: "Bienvenue sur vos rivages")
        case .protectionStarted: String(localized: "protection.mail.started", defaultValue: "Vos villages sont protégés pendant 72 heures")
        case .protectionExtended: String(localized: "protection.mail.extended", defaultValue: "Protection prolongée de 48 heures")
        case .protectionEnded: String(localized: "protection.mail.ended", defaultValue: "La protection initiale est terminée")
        case .raid(let report): report.won
            ? String(localized: "mail.raid.won", defaultValue: "Raid victorieux")
            : String(localized: "mail.raid.lost", defaultValue: "Raid repoussé")
        case .defense(let report): report.won
            ? String(localized: "mail.defense.won", defaultValue: "Votre village a résisté")
            : String(localized: "mail.defense.lost", defaultValue: "Votre village a été pillé")
        case .commerce(let report): report.successful
            ? String(localized: "mail.commerce.won", defaultValue: "Contrat maritime accompli")
            : String(localized: "mail.commerce.lost", defaultValue: "Convoi intercepté")
        case .colony: String(localized: "mail.colony.title", defaultValue: "Une nouvelle colonie est fondée")
        case .shipment: String(localized: "mail.shipment.title", defaultValue: "Ravitaillement livré")
        }
    }
    var summary: String {
        switch self {
        case .protectionStarted, .protectionExtended, .protectionEnded: String(localized: "protection.domain", defaultValue: "Tous vos villages")
        case .heroMission(let report): report.mission.title
        case .welcome: String(localized: "mail.welcome.summary", defaultValue: "Le conseil du port vous accompagne dans vos premiers pas.")
        case .raid(let report): report.targetName
        case .defense(let report): report.attackerName ?? String(localized: "mail.garrison", defaultValue: "La garnison")
        case .commerce(let report): report.order.route.name
        case .colony(let voyage): voyage.role.name + " · \(voyage.destination.x), \(voyage.destination.y)"
        case .shipment(let order): "\(order.destination.x), \(order.destination.y)"
        }
    }
    var symbol: String {
        switch self {
        case .heroMission: "sailboat.fill"
        case .welcome: "envelope.open.fill"
        case .protectionStarted, .protectionExtended, .protectionEnded: "shield.lefthalf.filled"
        case .raid: "flag.fill"
        case .defense: "shield.fill"
        case .commerce, .shipment: "shippingbox.fill"
        case .colony: "house.and.flag.fill"
        }
    }
    var tint: Color {
        switch self {
        case .raid(let report): report.won ? Color(red: 0.48, green: 0.84, blue: 0.67) : Color(red: 1, green: 0.58, blue: 0.46)
        case .defense(let report): report.won ? Color(red: 0.48, green: 0.84, blue: 0.67) : Color(red: 1, green: 0.58, blue: 0.46)
        case .commerce(let report): report.successful ? Palette.amber : Color(red: 1, green: 0.58, blue: 0.46)
        default: Palette.amber
        }
    }
}
