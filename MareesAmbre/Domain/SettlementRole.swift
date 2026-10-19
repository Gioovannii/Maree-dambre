import Foundation

enum SettlementRole: String, Codable, CaseIterable, Identifiable {
    case production, commerce, outpost
    var id: Self { self }
    var name: String {
        switch self {
        case .production: String(localized: "expansion.role.production", defaultValue: "Colonie forestière")
        case .commerce: String(localized: "expansion.role.commerce", defaultValue: "Comptoir d’ambre")
        case .outpost: String(localized: "expansion.role.outpost", defaultValue: "Avant-poste")
        }
    }
    var benefit: String {
        switch self {
        case .production: String(localized: "expansion.role.production.effect", defaultValue: "Production de bois augmentée de 20 pour cent.")
        case .commerce: String(localized: "expansion.role.commerce.effect", defaultValue: "Production d’ambre augmentée de 20 pour cent.")
        case .outpost: String(localized: "expansion.role.outpost.effect", defaultValue: "20 points de défense permanente supplémentaires.")
        }
    }
    var symbol: String {
        switch self { case .production: "tree.fill"; case .commerce: "sparkles"; case .outpost: "shield.fill" }
    }
}
