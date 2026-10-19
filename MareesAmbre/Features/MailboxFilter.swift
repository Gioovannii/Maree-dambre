import Foundation

enum MailboxFilter: CaseIterable, Identifiable {
    case all, unread, reports, messages
    var id: Self { self }
    var title: String {
        switch self {
        case .all: String(localized: "mail.filter.all", defaultValue: "Tout")
        case .unread: String(localized: "mail.filter.unread", defaultValue: "Non lus")
        case .reports: String(localized: "mail.filter.reports", defaultValue: "Rapports")
        case .messages: String(localized: "mail.filter.messages", defaultValue: "Messages")
        }
    }
    func includes(_ mail: GameMail) -> Bool {
        switch self {
        case .all: true
        case .unread: !mail.isRead
        case .reports: mail.content.isReport
        case .messages: !mail.content.isReport
        }
    }
}
