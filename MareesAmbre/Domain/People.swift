import Foundation

enum People: String, Codable, CaseIterable, Identifiable {
    case sauniers
    case nacre
    case roseaux

    var id: Self { self }

    var name: String {
        switch self {
        case .sauniers: L10n.text("Humains", "Humans")
        case .nacre: L10n.text("Peuple des récifs", "Reef Folk")
        case .roseaux: L10n.text("Elfes des marais", "Marsh Elves")
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
        case .sauniers: L10n.text("Navigateurs, bâtisseurs et commerçants. Leurs expéditions privilégient le transport des ressources.", "Sailors, builders and traders. Their expeditions excel at carrying resources.")
        case .nacre: L10n.text("Un peuple amphibie à la peau nacrée. Ses gardiens et ses mages combattent ensemble.", "An amphibious people with pearlescent skin. Their guardians and mages fight together.")
        case .roseaux: L10n.text("Des elfes des lagunes et des mangroves. Leurs expéditions reviennent plus vite.", "Elves of lagoons and mangroves. Their expeditions return sooner.")
        }
    }

    var strength: String {
        switch self {
        case .sauniers: L10n.text("+20 % de capacité de transport · +10 % de bois", "+20% carrying capacity · +10% wood")
        case .nacre: L10n.text("Les mages réduisent les pertes lors des victoires", "Mages reduce losses in victorious battles")
        case .roseaux: L10n.text("Expéditions de 90 s au lieu de 120 s · +10 % d’ambre", "90-second expeditions instead of 120 · +10% amber")
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
