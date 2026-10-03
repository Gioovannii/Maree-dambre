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
        case .tideguard: String(localized: "domain.army_unit.spearman", defaultValue: "Lancier")
        case .pillager: String(localized: "domain.army_unit.raider", defaultValue: "Pillard")
        case .amberSentry: String(localized: "domain.army_unit.guardian", defaultValue: "Gardien")
        case .tideMage: String(localized: "domain.army_unit.tide_mage", defaultValue: "Mage des marées")
        case .reedrunner: String(localized: "domain.army_unit.warrior", defaultValue: "Guerrier")
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
        case .tideguard: String(localized: "domain.army_unit.versatile_infantry", defaultValue: "Infanterie polyvalente")
        case .pillager: String(localized: "domain.army_unit.loot_carrier", defaultValue: "Transport du butin")
        case .amberSentry: String(localized: "domain.army_unit.heavy_infantry", defaultValue: "Infanterie puissante")
        case .tideMage: String(localized: "domain.army_unit.group_protection", defaultValue: "Protection du groupe")
        case .reedrunner: String(localized: "domain.army_unit.light_infantry", defaultValue: "Infanterie légère")
        case .marshArcher: String(localized: "domain.army_unit.ranged_attack", defaultValue: "Attaque à distance")
        }
    }
    var description: String {
        switch self {
        case .tideguard: String(localized: "domain.army_unit.a_spear_and_shield_form_the_backbone_of_human_expeditions", defaultValue: "Une lance et un bouclier pour former le cœur des expéditions humaines.")
        case .pillager: String(localized: "domain.army_unit.weaker_than_a_spearman_but_able_to_bring_back_more_resources", defaultValue: "Moins puissant qu’un lancier, mais capable de rapporter davantage de ressources.")
        case .amberSentry: String(localized: "domain.army_unit.a_reef_fighter_in_pearlescent_armor_powerful_but_expensive", defaultValue: "Un combattant des récifs à l’armure nacrée, puissant mais coûteux.")
        case .tideMage: String(localized: "domain.army_unit.with_at_least_one_mage_losses_on_victory_drop_from_20_to_15_the_bonus_does_not_stack", defaultValue: "Avec au moins un mage, les pertes en cas de victoire passent de 20 % à 15 %. Le bonus ne se cumule pas.")
        case .reedrunner: String(localized: "domain.army_unit.an_elf_with_a_light_spear_inexpensive_and_a_capable_carrier", defaultValue: "Un elfe équipé d’une lance légère, peu coûteux et bon porteur.")
        case .marshArcher: String(localized: "domain.army_unit.a_shortbow_strengthens_the_attack_power_of_elven_expeditions", defaultValue: "Un arc court pour renforcer la force d’attaque des expéditions elfiques.")
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
