import Foundation

enum ArmyUnit: String, CaseIterable, Codable, Identifiable, Sendable {
    case tideguard, reedrunner, amberSentry

    var id: Self { self }

    var name: String {
        switch self {
        case .tideguard: "Garde des passes"
        case .reedrunner: "Éclaireur des roseaux"
        case .amberSentry: "Sentinelle d’ambre"
        }
    }

    var role: String {
        switch self {
        case .tideguard: "Défense lourde"
        case .reedrunner: "Exploration rapide"
        case .amberSentry: "Protection des convois"
        }
    }

    var description: String {
        switch self {
        case .tideguard: "Tient les ponts et les quais. Résiste aux attaques et protège les bâtiments proches."
        case .reedrunner: "Traverse les chenaux et révèle les cases voisines plus vite que les autres unités."
        case .amberSentry: "Escorte les expéditions d’ambre et réduit les pertes sur les routes marines."
        }
    }

    var emblem: String {
        switch self {
        case .tideguard: "shield.lefthalf.filled"
        case .reedrunner: "figure.run"
        case .amberSentry: "sparkles"
        }
    }
}
