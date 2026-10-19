import SwiftUI

struct MailboxRow: View {
    let mail: GameMail
    @Environment(VillageSession.self) private var session
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: mail.content.symbol)
                .font(.title3).foregroundStyle(mail.content.tint)
                .frame(width: 44, height: 44)
                .background(mail.content.tint.opacity(0.12), in: .rect(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(mail.content.title).font(.headline)
                Text(mail.content.summary).font(.subheadline).foregroundStyle(Palette.muted)
                Text(session.settlementName(at: mail.village)).font(.caption).foregroundStyle(Palette.amber)
                if mail.imported == true {
                    Text(String(localized: "mail.imported", defaultValue: "Rapport antérieur"))
                        .font(.caption2).foregroundStyle(Palette.muted)
                } else {
                    Text(mail.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption2).foregroundStyle(Palette.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 12) {
                if !mail.isRead {
                    Circle().fill(Palette.amber).frame(width: 8, height: 8)
                }
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(Palette.muted)
            }
            .padding(.top, 5).accessibilityHidden(true)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 18))
        .overlay { RoundedRectangle(cornerRadius: 18).strokeBorder(mail.isRead ? Palette.muted.opacity(0.12) : Palette.amber.opacity(0.45)) }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityValue(mail.isRead
            ? String(localized: "mail.read", defaultValue: "Lu")
            : String(localized: "mail.unread", defaultValue: "Non lu"))
    }
}
