import Foundation

enum LighthouseStage: Int, CaseIterable, Codable {
    case jetties, tower, heart, lens, light

    var title: String {
        switch self {
        case .jetties: String(localized: "lighthouse.jetties", defaultValue: "Restaurer les jetées")
        case .tower: String(localized: "lighthouse.tower", defaultValue: "Relever la tour")
        case .heart: String(localized: "lighthouse.heart", defaultValue: "Réparer le cœur d’ambre")
        case .lens: String(localized: "lighthouse.lens", defaultValue: "Poser la lentille")
        case .light: String(localized: "lighthouse.light", defaultValue: "Allumer le Grand Phare")
        }
    }
    var cost: Resources {
        switch self {
        case .jetties: Resources(wood: 1200, amber: 600, provisions: 900)
        case .tower: Resources(wood: 2600, amber: 1200, provisions: 1800)
        case .heart: Resources(wood: 2000, amber: 4000, provisions: 2500)
        case .lens: Resources(wood: 3200, amber: 4200, provisions: 3000)
        case .light: Resources(wood: 5000, amber: 5000, provisions: 5000)
        }
    }
    var duration: TimeInterval { TimeInterval([2, 4, 6, 8, 12][rawValue]) * 3600 }
}
