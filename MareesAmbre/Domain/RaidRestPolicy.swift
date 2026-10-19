import Foundation

enum RaidRestPolicy {
    static let reminderLeadTime: TimeInterval = 3600

    static func isQuiet(at date: Date, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return hour >= 22 || hour < 8
    }

    /// Night protection ends at 08:00; automatic attacks resume at 09:00 for an extra preparation hour.
    static func allowsAutomaticAttack(at date: Date, calendar: Calendar = .current) -> Bool {
        (9..<22).contains(calendar.component(.hour, from: date))
    }

    static func attackDate(for date: Date, calendar: Calendar = .current) -> Date {
        guard !allowsAutomaticAttack(at: date, calendar: calendar) else { return date }
        return calendar.nextDate(after: date, matching: DateComponents(hour: 9, minute: 0, second: 0),
                                 matchingPolicy: .nextTime, repeatedTimePolicy: .first) ?? date.addingTimeInterval(24 * 3600)
    }

    static func reminderDate(for attack: Date?, now: Date, previousReminder: Date? = nil, calendar: Calendar = .current) -> Date? {
        guard let attack else { return nil }
        let date = attack.addingTimeInterval(-reminderLeadTime)
        guard date > now, !isQuiet(at: date, calendar: calendar) else { return nil }
        if let previousReminder, previousReminder <= now, calendar.isDate(previousReminder, inSameDayAs: date) { return nil }
        return date
    }
}
