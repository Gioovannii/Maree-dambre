import Foundation

extension People {
    var specialtyBuilding: BuildingKind {
        switch self {
        case .sauniers: .market
        case .nacre: .watchtower
        case .roseaux: .academy
        }
    }

    var specialtyTitle: String {
        switch self {
        case .sauniers: String(localized: "people.specialty.human.title", defaultValue: "Logistique des comptoirs")
        case .nacre: String(localized: "people.specialty.reef.title", defaultValue: "Rempart des récifs")
        case .roseaux: String(localized: "people.specialty.elf.title", defaultValue: "Sentiers des marais")
        }
    }

    var specialtyDescription: String {
        switch self {
        case .sauniers: String(localized: "people.specialty.human.body", defaultValue: "Le Marché ajoute 5 points de bonus de transport par niveau, jusqu’à 20 points. Les expéditions et les ravitaillements en profitent.")
        case .nacre: String(localized: "people.specialty.reef.body", defaultValue: "La Tour de garde ajoute 5 points de défense supplémentaires par niveau. Cette protection reste au village quand les troupes partent.")
        case .roseaux: String(localized: "people.specialty.elf.body", defaultValue: "L’Académie réduit le temps supplémentaire des raids lointains de 2 points de pourcentage par niveau, jusqu’à 20 %. Le trajet de base reste identique.")
        }
    }
}

extension VillageState {
    var specialtyTransportBonus: Int { people == .sauniers ? min(20, 5 * buildingLevel(.market)) : 0 }
    var specialtyDefenseBonus: Int { people == .nacre ? 5 * buildingLevel(.watchtower) : 0 }
    var distantRaidDurationMultiplier: Double {
        people == .roseaux ? 1 - Double(min(20, 2 * buildingLevel(.academy))) / 100 : 1
    }
}
