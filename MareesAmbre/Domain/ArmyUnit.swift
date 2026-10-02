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
        case .tideguard: L10n.text("Lancier", "Spearman")
        case .pillager: L10n.text("Pillard", "Raider")
        case .amberSentry: L10n.text("Gardien", "Guardian")
        case .tideMage: L10n.text("Mage des marées", "Tide Mage")
        case .reedrunner: L10n.text("Guerrier", "Warrior")
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
        case .tideguard: L10n.text("Infanterie polyvalente", "Versatile infantry")
        case .pillager: L10n.text("Transport du butin", "Loot carrier")
        case .amberSentry: L10n.text("Infanterie puissante", "Heavy infantry")
        case .tideMage: L10n.text("Protection du groupe", "Group protection")
        case .reedrunner: L10n.text("Infanterie légère", "Light infantry")
        case .marshArcher: L10n.text("Attaque à distance", "Ranged attack")
        }
    }
    var description: String {
        switch self {
        case .tideguard: L10n.text("Une lance et un bouclier pour former le cœur des expéditions humaines.", "A spear and shield form the backbone of human expeditions.")
        case .pillager: L10n.text("Moins puissant qu’un lancier, mais capable de rapporter davantage de ressources.", "Weaker than a spearman, but able to bring back more resources.")
        case .amberSentry: L10n.text("Un combattant des récifs à l’armure nacrée, puissant mais coûteux.", "A reef fighter in pearlescent armor. Powerful, but expensive.")
        case .tideMage: L10n.text("Avec au moins un mage, les pertes en cas de victoire passent de 20 % à 15 %. Le bonus ne se cumule pas.", "With at least one mage, losses on victory drop from 20% to 15%. The bonus does not stack.")
        case .reedrunner: L10n.text("Un elfe équipé d’une lance légère, peu coûteux et bon porteur.", "An elf with a light spear: inexpensive and a capable carrier.")
        case .marshArcher: L10n.text("Un arc court pour renforcer la force d’attaque des expéditions elfiques.", "A shortbow strengthens the attack power of elven expeditions.")
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
