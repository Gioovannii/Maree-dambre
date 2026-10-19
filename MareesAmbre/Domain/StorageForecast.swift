import Foundation

/// Estimate at the current production rate, before future spending or deliveries.
enum StorageForecast {
    static func timeUntilFull(stock: Int, capacity: Int, hourlyRate: Int) -> TimeInterval? {
        guard stock < capacity else { return 0 }
        guard hourlyRate > 0 else { return nil }
        return Double(capacity - stock) / Double(hourlyRate) * 3600
    }
}
