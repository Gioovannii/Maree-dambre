import SwiftUI

struct MailboxPanel: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var filter = MailboxFilter.all
    @State private var opened: GameMail?
    private var visible: [GameMail] { session.state.allMail.filter(filter.includes) }

    private var controlsLayout: AnyLayout {
        typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) : AnyLayout(HStackLayout(alignment: .top))
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(String(localized: "mail.title", defaultValue: "Messagerie"), systemImage: "tray.full.fill")
                .font(.title2.bold()).fontDesign(.serif).foregroundStyle(Palette.amber)
            Text(String(localized: "mail.subtitle", defaultValue: "Messages du conseil et rapports de tous vos villages."))
                .font(.subheadline).foregroundStyle(Palette.muted)
            controlsLayout {
                Text(String(localized: "mail.unread_count", defaultValue: "\(String(session.state.unreadMailCount)) non lus"))
                    .font(.subheadline.bold())
                Spacer(minLength: 8)
                Button(String(localized: "mail.mark_all", defaultValue: "Tout marquer comme lu"), action: session.markAllMailRead)
                    .font(.footnote.bold()).buttonStyle(.bordered)
                    .disabled(session.state.unreadMailCount == 0)
                    .accessibilityIdentifier("mail.markAllRead")
            }
            Picker(String(localized: "mail.filter", defaultValue: "Afficher"), selection: $filter) {
                ForEach(MailboxFilter.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu).accessibilityIdentifier("mail.filter")
            if visible.isEmpty {
                ContentUnavailableView(String(localized: "mail.empty", defaultValue: "Aucun message à afficher"), systemImage: "tray",
                    description: Text(String(localized: "mail.empty.help", defaultValue: "Vos prochains messages et rapports apparaîtront ici. Vous pouvez aussi changer le filtre.")))
            } else {
                ForEach(visible) { mail in
                    Button {
                        session.markMailRead(mail.id)
                        opened = mail
                    } label: { MailboxRow(mail: mail) }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("mail.open.\(mail.id)")
                }
            }
        }
        .foregroundStyle(Palette.paper).tint(Palette.amber)
        .sheet(item: $opened) { MailDetailSheet(mail: $0) }
        .task {
            if ProcessInfo.processInfo.arguments.contains("--snapshot-mail-detail"),
               let mail = session.state.allMail.first(where: { if case .raid = $0.content { true } else { false } }) {
                session.markMailRead(mail.id)
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { opened = mail }
            }
        }
    }
}
