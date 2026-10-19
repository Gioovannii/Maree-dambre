import Foundation

enum VillageGuideStep: String, Codable, CaseIterable {
    case fields, academy, research, barracks, train, raid, complete

    static func next(in village: VillageState) -> Self {
        let completed = village.completedGuideObjectives
        return allCases.first { $0 != .complete && !completed.contains($0) } ?? .complete
    }

    var destination: String {
        switch self {
        case .fields: "resources"
        case .academy, .research, .barracks, .train: "town"
        case .raid: "missions"
        case .complete: "town"
        }
    }

    var advice: String {
        switch self {
        case .complete: String(localized: "guide.complete", defaultValue: "Préparons ton deuxième village. Dans Monde, ouvre Colonisation : améliore la capitale, recherche la navigation, prépare les colons puis choisis une terre. Un refuge permet de vivre sans subir d’attaques.")
        case .fields: String(localized: "guide.fields", defaultValue: "Commençons par la production. Ouvre Ressources, touche une parcelle puis améliore-la. Un seul chantier peut avancer à la fois.")
        case .academy: String(localized: "guide.academy", defaultValue: "Ton prochain objectif est la Maison des savoirs. Ouvre le Centre et choisis une parcelle libre pour la construire.")
        case .research: String(localized: "guide.research", defaultValue: "Ouvre la Maison des savoirs dans le Centre pour rechercher ta première unité. La recherche débloque le recrutement ; elle ne crée pas encore de troupes.")
        case .barracks: String(localized: "guide.barracks", defaultValue: "Construis la Cour des armes sur une parcelle libre du Centre. Tu pourras ensuite y entraîner les unités recherchées.")
        case .train: String(localized: "guide.train", defaultValue: "Ouvre la Cour des armes pour entraîner tes premières troupes. Si un entraînement est déjà en cours, attends son terme. Garde des ressources pour les prochaines améliorations.")
        case .raid: String(localized: "guide.raid", defaultValue: "Dans Missions, prépare une attaque contre un voisin proche. Compare les forces et les pertes prévues avant de choisir tes troupes. Une expédition en cours doit rentrer avant le prochain départ.")
        }
    }
}
