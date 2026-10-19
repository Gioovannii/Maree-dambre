import Foundation
import Observation
import UserNotifications

@Observable @MainActor
final class RaidReminderController {
    private static let identifier = "mareesambre.next-raid"
    private let defaults: UserDefaults
    private let center = UNUserNotificationCenter.current()
    private let isSnapshot = ProcessInfo.processInfo.arguments.contains("--ui-snapshot")
    private var desiredAttack: Date?
    private var isSynchronizing = false
    private var needsSynchronization = false
    private var scheduledAttack: Date?
    private(set) var isEnabled: Bool
    private(set) var isRequesting = false
    private(set) var permissionDenied = false
    private(set) var schedulingFailed = false
    private(set) var scheduledReminder: Date?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = !ProcessInfo.processInfo.arguments.contains("--ui-snapshot") && defaults.bool(forKey: "raidReminder.enabled")
    }

    func enable(attack: Date?) async {
        guard !isSnapshot, !isRequesting else { return }
        isRequesting = true
        defer { isRequesting = false }
        do {
            let allowed = try await center.requestAuthorization(options: [.alert])
            permissionDenied = !allowed
            guard allowed else { return }
            isEnabled = true
            defaults.set(true, forKey: "raidReminder.enabled")
            await synchronize(attack: attack)
        } catch { schedulingFailed = true }
    }

    func disable() {
        isEnabled = false
        defaults.set(false, forKey: "raidReminder.enabled")
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])
        scheduledReminder = nil
        needsSynchronization = true
    }

    /// A single serialized worker coalesces changes and avoids an old request winning a race with opt-out.
    func synchronize(attack: Date?) async {
        guard !isSnapshot else { return }
        desiredAttack = attack
        needsSynchronization = true
        guard !isSynchronizing else { return }
        isSynchronizing = true
        defer { isSynchronizing = false }
        while needsSynchronization {
            needsSynchronization = false
            await apply(attack: desiredAttack)
        }
    }

    private func apply(attack: Date?) async {
        guard isEnabled else {
            center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])
            scheduledReminder = nil
            return
        }
        let settings = await center.notificationSettings()
        guard isEnabled else { return }
        permissionDenied = settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional
        let previous = defaults.object(forKey: "raidReminder.lastPlanned") as? Date
        guard !permissionDenied,
              let reminder = RaidRestPolicy.reminderDate(for: attack, now: .now, previousReminder: previous), let attack else {
            center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])
            scheduledReminder = nil
            return
        }
        guard scheduledReminder != reminder || scheduledAttack != attack else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "raid.reminder.title", defaultValue: "Vos villages se préparent")
        let date = attack.formatted(.dateTime.day().month().hour().minute())
        content.body = String(localized: "raid.reminder.body", defaultValue: "Un assaut est prévu le \(String(date)). Votre garnison défendra automatiquement ; le rapport vous attendra dans Messages.")
        content.threadIdentifier = "mareesambre.defense"
        // No sound, badge, urgency escalation or repeating trigger.
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        do {
            try await center.add(UNNotificationRequest(identifier: Self.identifier, content: content, trigger: trigger))
            guard isEnabled else {
                center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])
                return
            }
            scheduledReminder = reminder
            scheduledAttack = attack
            schedulingFailed = false
            defaults.set(reminder, forKey: "raidReminder.lastPlanned")
        } catch {
            scheduledReminder = nil
            schedulingFailed = true
        }
    }
}
