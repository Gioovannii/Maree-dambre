import Foundation

enum People: String, Codable, CaseIterable, Identifiable {
    case sauniers
    case nacre
    case roseaux

    var id: Self { self }

    var name: String {
        switch self {
        case .sauniers: "Humains"
        case .nacre: "Peuple des récifs"
        case .roseaux: "Elfes des marais"
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
        case .sauniers: "Navigateurs, bâtisseurs et commerçants. Leurs expéditions privilégient le transport des ressources."
        case .nacre: "Un peuple amphibie à la peau nacrée. Ses gardiens et ses mages combattent ensemble."
        case .roseaux: "Des elfes des lagunes et des mangroves. Leurs expéditions reviennent plus vite."
        }
    }

    var strength: String {
        switch self {
        case .sauniers: "+20 % de capacité de transport · +10 % de bois"
        case .nacre: "Les mages réduisent les pertes lors des victoires"
        case .roseaux: "Expéditions de 90 s au lieu de 120 s · +10 % d’ambre"
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
