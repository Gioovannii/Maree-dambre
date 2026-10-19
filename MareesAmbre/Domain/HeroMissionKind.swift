import Foundation

enum HeroMissionKind: String, Codable, CaseIterable, Identifiable {
    case discoverWreck, recoverBoat, repairBoat, surveyCoast, rescueCrew
    var id: String { rawValue }
    var chapter: Int? {
        switch self { case .discoverWreck: 0; case .recoverBoat: 1; case .repairBoat: 2; default: nil }
    }
    var baseDuration: TimeInterval {
        switch self { case .discoverWreck: 600; case .recoverBoat: 1200; case .repairBoat: 1800; case .surveyCoast: 1200; case .rescueCrew: 2700 }
    }
    var experience: Int {
        switch self { case .discoverWreck: 30; case .recoverBoat: 50; case .repairBoat: 75; case .surveyCoast: 20; case .rescueCrew: 40 }
    }
    var materials: Int {
        switch self { case .discoverWreck: 2; case .recoverBoat: 3; case .repairBoat: 0; case .surveyCoast: 1; case .rescueCrew: 2 }
    }
    var materialCost: Int { self == .repairBoat ? 5 : 0 }
    var cost: Resources {
        self == .repairBoat ? Resources(wood: 200, amber: 80, provisions: 100) : Resources(wood: 0, amber: 0, provisions: 0)
    }
    var title: String {
        switch self {
        case .discoverWreck: String(localized: "hero.mission.discover", defaultValue: "La coque oubliée")
        case .recoverBoat: String(localized: "hero.mission.recover", defaultValue: "Ramener la barque")
        case .repairBoat: String(localized: "hero.mission.repair", defaultValue: "Une nouvelle voile")
        case .surveyCoast: String(localized: "hero.mission.survey", defaultValue: "Cartographier les criques")
        case .rescueCrew: String(localized: "hero.mission.rescue", defaultValue: "Secourir un équipage")
        }
    }
    var summary: String {
        switch self {
        case .discoverWreck: String(localized: "hero.mission.discover_body", defaultValue: "Explorez un ancien mouillage. Une coque semble encore pouvoir naviguer.")
        case .recoverBoat: String(localized: "hero.mission.recover_body", defaultValue: "Ramenez la barque à l’abri et récupérez les pièces nécessaires à sa remise en état.")
        case .repairBoat: String(localized: "hero.mission.repair_body", defaultValue: "Réparez la coque et installez une voile. Votre capitaine disposera de sa propre barque.")
        case .surveyCoast: String(localized: "hero.mission.survey_body", defaultValue: "Relevez les passages entre les récifs et récupérez du matériel maritime.")
        case .rescueCrew: String(localized: "hero.mission.rescue_body", defaultValue: "Rejoignez un navire échoué et aidez son équipage à regagner la côte.")
        }
    }
    var symbol: String {
        switch self { case .discoverWreck: "binoculars.fill"; case .recoverBoat: "water.waves"; case .repairBoat: "hammer.fill"; case .surveyCoast: "map.fill"; case .rescueCrew: "lifepreserver.fill" }
    }
}
