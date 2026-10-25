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
        case .sauniers: String(localized: "people.strength.transport", defaultValue: "Capacité de transport des expéditions augmentée de 20 pour cent")
        case .nacre: String(localized: "domain.people.mages_reduce_losses_in_victorious_battles", defaultValue: "Les mages réduisent les pertes lors des victoires")
        case .roseaux: String(localized: "people.strength.travel", defaultValue: "Trajet de base des expéditions : 90 s au lieu de 120 s")
        }
    }

    var baseDefenseBonus: Int { self == .nacre ? 1 : 0 }

    func adjustedProduction(_ base: Resources) -> Resources { base }

    var playStyle: String {
        switch self {
        case .sauniers: String(localized: "people.style.human", defaultValue: "Polyvalence et transport")
        case .nacre: String(localized: "people.style.reef", defaultValue: "Défense et protection")
        case .roseaux: String(localized: "people.style.elf", defaultValue: "Raids rapides et troupes abordables")
        }
    }

    var tacticalAdvice: String {
        switch self {
        case .sauniers: String(localized: "people.tactics.human", defaultValue: "Les lanciers assurent les combats et la défense. Ajoutez des pillards pour rapporter plus de butin ; leur défense est plus faible. Le marché renforce le transport des raids et des ravitaillements.")
        case .nacre: String(localized: "people.tactics.reef", defaultValue: "Gardez des gardiens en garnison et développez la tour de garde : sa défense reste au village quand les troupes partent. Un mage dans une expédition réduit les pertes en cas de victoire ; plusieurs mages ne cumulent pas cet effet.")
        case .roseaux: String(localized: "people.tactics.elf", defaultValue: "Les guerriers coûtent peu de ressources et transportent davantage que les archers. Les archers apportent plus de puissance de combat et de défense. L’académie raccourcit le supplément de trajet des raids lointains.")
        }
    }
}
