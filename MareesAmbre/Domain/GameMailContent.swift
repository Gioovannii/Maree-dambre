import Foundation

enum GameMailContent: Codable, Equatable {
    case welcome
    case heroMission(HeroMissionReport)
    case protectionStarted(Date), protectionExtended(Date), protectionEnded
    case raid(RaidReport)
    case defense(DefenseReport)
    case commerce(ConvoyReport)
    case colony(FoundingVoyage)
    case shipment(SettlementShipment)

    var isReport: Bool {
        switch self { case .welcome, .colony, .protectionStarted, .protectionExtended, .protectionEnded: false; default: true }
    }
    var isValid: Bool {
        switch self {
        case .heroMission(let report): report.isValid
        case .welcome, .protectionEnded: true
        case .protectionStarted(let end), .protectionExtended(let end): end >= .distantPast && end <= .distantFuture
        case .raid(let report): report.isValid
        case .defense(let report): report.isValid
        case .commerce(let report): report.isValid
        case .colony(let voyage): voyage.isValid
        case .shipment(let order): order.isValid && order.unloaded == order.cargo
        }
    }
}
