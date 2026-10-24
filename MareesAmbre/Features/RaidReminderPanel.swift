import SwiftUI

struct RaidReminderPanel: View {
    @Environment(RaidReminderController.self) private var reminders
    @Environment(VillageSession.self) private var session

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(String(localized: "raid.rest.title", defaultValue: "Des nuits tranquilles"), systemImage: "moon.zzz.fill")
                .font(.subheadline.bold()).foregroundStyle(Palette.amber)
            Text(String(localized: "raid.rest.body", defaultValue: "Protection nocturne de 22 h à 8 h, puis une heure de préparation : les raids automatiques reprennent à 9 h, heure locale."))
                .font(.footnote).foregroundStyle(Palette.muted)
            Text(String(localized: "raid.reminder.explanation", defaultValue: "Rappel facultatif une heure avant le prochain assaut. Au plus un rappel par jour pour tous vos villages, sans son. Aucune présence à l’heure du combat n’est nécessaire."))
                .font(.footnote).foregroundStyle(Palette.muted)
            if reminders.isEnabled {
                if let date = reminders.scheduledReminder {
                    Text(String(localized: "raid.reminder.planned", defaultValue: "Rappel programmé"))
                        .font(.caption.bold())
                    Text(date, format: .dateTime.day().month().hour().minute()).font(.caption)
                }
                if reminders.scheduledReminder == nil && !reminders.permissionDenied && !reminders.schedulingFailed {
                    Text(String(localized: "raid.reminder.next", defaultValue: "Le prochain rappel sera programmé lorsqu’un nouvel assaut sera annoncé."))
                        .font(.caption).foregroundStyle(Palette.muted)
                }
                Button(String(localized: "raid.reminder.disable", defaultValue: "Désactiver le rappel"), systemImage: "bell.slash") { reminders.disable() }
                    .buttonStyle(.bordered)
            } else {
                Button {
                    Task { await reminders.enable(attack: session.reminderAttackDate) }
                } label: {
                    Label(String(localized: "raid.reminder.enable", defaultValue: "Activer un rappel discret"), systemImage: "bell")
                }
                .buttonStyle(.bordered).disabled(reminders.isRequesting)
                .accessibilityIdentifier("raid.reminder.enable")
            }
            if reminders.permissionDenied {
                Text(String(localized: "raid.reminder.denied", defaultValue: "Les notifications sont désactivées dans les réglages iOS. La protection nocturne reste active."))
                    .font(.caption).foregroundStyle(Palette.muted)
            }
            if reminders.schedulingFailed && reminders.isEnabled {
                Button(String(localized: "raid.reminder.retry", defaultValue: "Réessayer le rappel")) {
                    Task { await reminders.synchronize(attack: session.reminderAttackDate) }
                }.buttonStyle(.bordered)
            }
            if reminders.schedulingFailed {
                Text(String(localized: "raid.reminder.failed", defaultValue: "Le rappel n’a pas pu être programmé. Vous pouvez réessayer ; votre garnison défendra automatiquement."))
                    .font(.caption).foregroundStyle(Palette.muted)
            }
        }
        .disabled(session.isTestMode)
    }
}
