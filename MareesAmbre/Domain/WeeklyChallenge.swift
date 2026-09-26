import Foundation

enum WeeklyChallenge {
    // ISO week and UTC keep the seed identical across devices and time zones.
    static func seed(for date: Date) -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.component(.yearForWeekOfYear, from: date) * 100
            + calendar.component(.weekOfYear, from: date)
    }
}
