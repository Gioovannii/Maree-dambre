import Foundation

extension People {
    func specialtyBonus(at level: Int) -> Int {
        let bounded = min(GameProgression.maximumBuildingLevel, max(0, level))
        switch self {
        case .sauniers: return min(20, 5 * bounded)
        case .nacre: return 5 * bounded
        case .roseaux: return min(20, 2 * bounded)
        }
    }

    func specialtyEffect(at level: Int) -> String {
        let value = specialtyBonus(at: level)
        switch self {
        case .sauniers:
            return String(localized: "people.specialty.transport_value", defaultValue: "+\(String(value)) points de bonus de transport · plafond : 20")
        case .nacre:
            return String(localized: "people.specialty.defense_value", defaultValue: "+\(String(value)) de défense automatique supplémentaire")
        case .roseaux:
            let percent = (Double(value) / 100).formatted(.percent.precision(.fractionLength(0)))
            return String(localized: "people.specialty.travel_value", defaultValue: "Temps supplémentaire des raids lointains réduit de \(percent) · plafond : \((0.2).formatted(.percent.precision(.fractionLength(0))))")
        }
    }

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
    var specialtyTransportBonus: Int { people == .sauniers ? People.sauniers.specialtyBonus(at: buildingLevel(.market)) : 0 }
    var specialtyDefenseBonus: Int { people == .nacre ? People.nacre.specialtyBonus(at: buildingLevel(.watchtower)) : 0 }
    var distantRaidDurationMultiplier: Double {
        people == .roseaux ? 1 - Double(People.roseaux.specialtyBonus(at: buildingLevel(.academy))) / 100 : 1
    }
}
