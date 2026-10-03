import Foundation

enum People: String, Codable, CaseIterable, Identifiable {
    case sauniers
    case nacre
    case roseaux

    var id: Self { self }

    var name: String {
        switch self {
        case .sauniers: String(localized: "domain.people.humans", defaultValue: "Humains")
        case .nacre: String(localized: "domain.people.reef_folk", defaultValue: "Peuple des récifs")
        case .roseaux: String(localized: "domain.people.marsh_elves", defaultValue: "Elfes des marais")
        }
    }

    var emblem: String {
        switch self {
        case .sauniers: "sun.max.fill"
        case .nacre: "shield.lefthalf.filled"
        case .roseaux: "water.waves"
        }
    }

    var description: String {
        switch self {
        case .sauniers: String(localized: "domain.people.sailors_builders_and_traders_their_expeditions_excel_at_carrying_resources", defaultValue: "Navigateurs, bâtisseurs et commerçants. Leurs expéditions privilégient le transport des ressources.")
        case .nacre: String(localized: "domain.people.an_amphibious_people_with_pearlescent_skin_their_guardians_and_mages_fight_together", defaultValue: "Un peuple amphibie à la peau nacrée. Ses gardiens et ses mages combattent ensemble.")
        case .roseaux: String(localized: "domain.people.elves_of_lagoons_and_mangroves_their_expeditions_return_sooner", defaultValue: "Des elfes des lagunes et des mangroves. Leurs expéditions reviennent plus vite.")
        }
    }

    var strength: String {
        switch self {
        case .sauniers: String(localized: "domain.people.20_carrying_capacity_10_wood", defaultValue: "+20 % de capacité de transport · +10 % de bois")
        case .nacre: String(localized: "domain.people.mages_reduce_losses_in_victorious_battles", defaultValue: "Les mages réduisent les pertes lors des victoires")
        case .roseaux: String(localized: "domain.people.90_second_expeditions_instead_of_120_10_amber", defaultValue: "Expéditions de 90 s au lieu de 120 s · +10 % d’ambre")
        }
    }

    var baseDefenseBonus: Int { self == .nacre ? 1 : 0 }

    func adjustedProduction(_ base: Resources) -> Resources {
        func adjusted(_ amount: Int, by factor: Double) -> Int {
            Int((Double(amount) * factor).rounded())
        }
        switch self {
        case .sauniers:
            return Resources(wood: adjusted(base.wood, by: 1.1), amber: base.amber, provisions: base.provisions)
        case .nacre:
            return base
        case .roseaux:
            return Resources(wood: base.wood, amber: adjusted(base.amber, by: 1.1), provisions: base.provisions)
        }
    }
}
