import Foundation

// Original raw values remain stable so existing armies and research can be loaded.
enum ArmyUnit: String, CaseIterable, Codable, Identifiable, Sendable {
    case tideguard, reedrunner, amberSentry, pillager, tideMage, marshArcher
    var id: Self { self }
    var people: People {
        switch self {
        case .tideguard, .pillager: .sauniers
        case .amberSentry, .tideMage: .nacre
        case .reedrunner, .marshArcher: .roseaux
        }
    }
    var name: String {
        switch self {
        case .tideguard: "Lancier"
        case .pillager: "Pillard"
        case .amberSentry: "Gardien"
        case .tideMage: "Mage des marées"
        case .reedrunner: "Guerrier"
        case .marshArcher: "Archer"
        }
    }
    var imageAssetName: String {
        switch self {
        case .tideguard: "UniteLancier"
        case .pillager: "UnitePillard"
        case .amberSentry: "UniteGardien"
        case .tideMage: "UniteMageMarees"
        case .reedrunner: "UniteGuerrier"
        case .marshArcher: "UniteArcher"
        }
    }
    var role: String {
        switch self {
        case .tideguard: "Infanterie polyvalente"
        case .pillager: "Transport du butin"
        case .amberSentry: "Infanterie puissante"
        case .tideMage: "Protection du groupe"
        case .reedrunner: "Infanterie légère"
        case .marshArcher: "Attaque à distance"
        }
    }
    var description: String {
        switch self {
        case .tideguard: "Une lance et un bouclier pour former le cœur des expéditions humaines."
        case .pillager: "Moins puissant qu’un lancier, mais capable de rapporter davantage de ressources."
        case .amberSentry: "Un combattant des récifs à l’armure nacrée, puissant mais coûteux."
        case .tideMage: "Avec au moins un mage, les pertes en cas de victoire passent de 20 % à 15 %. Le bonus ne se cumule pas."
        case .reedrunner: "Un elfe équipé d’une lance légère, peu coûteux et bon porteur."
        case .marshArcher: "Un arc court pour renforcer la force d’attaque des expéditions elfiques."
        }
    }
    var emblem: String {
        switch self {
        case .tideguard, .amberSentry: "shield.lefthalf.filled"
        case .pillager: "shippingbox.fill"
        case .reedrunner: "figure.run"
        case .tideMage: "sparkles"
        case .marshArcher: "scope"
        }
    }
}
