import Foundation

enum People: String, Codable, CaseIterable, Identifiable {
    case sauniers
    case nacre
    case roseaux

    var id: Self { self }

    var name: String {
        switch self {
        case .sauniers: "Les Sauniers"
        case .nacre: "La Garde de Nacre"
        case .roseaux: "Le Pacte des Roseaux"
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
        case .sauniers: "Bâtisseurs des salines et des forêts côtières, ils savent tirer du bois de chaque rivage."
        case .nacre: "Gardiens des passes et des cités portuaires, ils préfèrent tenir leurs positions."
        case .roseaux: "Navigateurs des chenaux, ils recherchent les filons d’ambre cachés sous les eaux."
        }
    }

    var strength: String {
        switch self {
        case .sauniers: "+10 % de production de bois"
        case .nacre: "+1 défense automatique de base"
        case .roseaux: "+10 % de production d’ambre"
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
