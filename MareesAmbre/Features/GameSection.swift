import Foundation

enum GameSection: CaseIterable, Identifiable {
    case resources, town, world, missions, mailbox
    var id: Self { self }
    var title: String {
        switch self {
        case .resources: String(localized: "screen.game.resources", defaultValue: "Ressources")
        case .town: String(localized: "screen.game.town", defaultValue: "Centre")
        case .world: String(localized: "screen.game.world", defaultValue: "Monde")
        case .missions: String(localized: "screen.game.missions", defaultValue: "Missions")
        case .mailbox: String(localized: "mail.tab", defaultValue: "Messages")
        }
    }
    var symbol: String {
        switch self {
        case .resources: "leaf.fill"
        case .town: "building.2.fill"
        case .world: "map.fill"
        case .missions: "sailboat.fill"
        case .mailbox: "envelope.fill"
        }
    }
}
