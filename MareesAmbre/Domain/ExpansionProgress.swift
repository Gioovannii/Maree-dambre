import Foundation

struct ExpansionProgress: Codable, Equatable {
    var researched = false
    var researchEndsAt: Date?
    var settlersReady = false
    var settlersEndAt: Date?
    var voyage: FoundingVoyage?

    var isValid: Bool {
        let dates = [researchEndsAt, settlersEndAt, voyage?.arrivesAt].compactMap { $0 }
        return dates.allSatisfy { $0 >= .distantPast && $0 <= .distantFuture }
            && !(researched && researchEndsAt != nil)
            && (!settlersReady || (researched && settlersEndAt == nil && voyage == nil))
            && (settlersEndAt == nil || (researched && !settlersReady && voyage == nil))
            && (voyage == nil || (researched && !settlersReady && settlersEndAt == nil))
            && (voyage?.isValid ?? true)
    }
}
