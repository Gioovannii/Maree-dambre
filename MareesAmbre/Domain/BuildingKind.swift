enum BuildingKind: String, Codable, CaseIterable, Identifiable {
    case hall, lumbermill, farm, amberWorks, watchtower, warehouse, warCourt, academy
    var id: Self { self }
    var requiredResourceSite: ResourceSiteKind? {
        switch self {
        case .lumbermill: .woodland
        case .farm: .cropland
        case .amberWorks: .amberVein
        default: nil
        }
    }
    static let constructible: [Self] = [.lumbermill, .farm, .amberWorks, .watchtower, .warehouse, .warCourt, .academy]
    static func constructible(in area: VillageMapMode) -> [Self] {
        constructible.filter { $0.area == area }
    }

    var area: VillageMapMode {
        switch self {
        case .hall, .lumbermill, .farm, .amberWorks, .watchtower, .warehouse, .warCourt, .academy: .townCenter
        }
    }

    func suits(_ terrain: Terrain) -> Bool {
        switch self {
        case .hall: false
        case .lumbermill, .farm, .amberWorks, .watchtower, .warehouse, .warCourt, .academy: terrain == .meadow
        }
    }
    var name: String {
        switch self {
        case .hall: "Maison des Veilleurs"
        case .lumbermill: "Scierie"
        case .farm: "Ferme"
        case .amberWorks: "Atelier d’ambre"
        case .watchtower: "Tour de garde"
        case .warehouse: "Entrepôt"
        case .warCourt: "Cour des armes"
        case .academy: "Maison des savoirs"
        }
    }
    var purpose: String {
        switch self {
        case .hall: "Cœur du village : elle assure les premières ressources sans interruption."
        case .lumbermill: "Transforme le bois de la forêt en réserves pour les chantiers."
        case .farm: "Cultive des vivres pour soutenir la croissance du village."
        case .amberWorks: "Extrait et travaille l’ambre présent dans ce gisement."
        case .watchtower: "Renforce la défense automatique du village."
        case .warehouse: "Augmente la quantité de ressources que le village peut conserver."
        case .warCourt: "Entraîne les unités débloquées par la Maison des savoirs."
        case .academy: "Étudie les doctrines qui débloquent de nouvelles unités."
        }
    }

    var imageAssetName: String? {
        switch self {
        case .hall: "MaisonVeilleurs"
        case .lumbermill: "Scierie"
        case .farm: "Ferme"
        case .amberWorks: "AtelierAmbre"
        case .watchtower: "TourDeGarde"
        case .warehouse: "Entrepot"
        case .warCourt: "CourArmes"
        case .academy: "MaisonSavoirs"
        }
    }

    var symbol: String {
        switch self {
        case .hall: "building.2.fill"
        case .lumbermill: "tree.fill"
        case .farm: "leaf.fill"
        case .amberWorks: "sparkles"
        case .watchtower: "binoculars.fill"
        case .warehouse: "shippingbox.fill"
        case .warCourt: "shield.lefthalf.filled"
        case .academy: "book.closed.fill"
        }
    }
    var cost: Resources {
        switch self {
        case .hall: Resources(wood: 0, amber: 0, provisions: 0)
        case .lumbermill: Resources(wood: 25, amber: 5, provisions: 10)
        case .farm: Resources(wood: 20, amber: 0, provisions: 5)
        case .amberWorks: Resources(wood: 35, amber: 10, provisions: 15)
        case .watchtower: Resources(wood: 35, amber: 8, provisions: 20)
        case .warehouse: Resources(wood: 45, amber: 5, provisions: 25)
        case .warCourt: Resources(wood: 25, amber: 5, provisions: 10)
        case .academy: Resources(wood: 20, amber: 10, provisions: 5)
        }
    }
    var yield: Resources {
        switch self {
        case .hall: Resources(wood: 2, amber: 1, provisions: 2)
        case .lumbermill: Resources(wood: 8, amber: 0, provisions: 0)
        case .farm: Resources(wood: 0, amber: 0, provisions: 8)
        case .amberWorks: Resources(wood: 0, amber: 4, provisions: 0)
        case .watchtower, .warehouse, .warCourt, .academy: Resources(wood: 0, amber: 0, provisions: 0)
        }
    }
    var productionText: String {
        return switch self {
        case .hall: "+2 bois · +1 ambre · +2 vivres / h"
        case .lumbermill: "+8 bois / h"
        case .farm: "+8 vivres / h"
        case .amberWorks: "+4 ambre / h"
        case .watchtower: "+2 défense automatique"
        case .warehouse: "+500 de capacité de réserve"
        case .warCourt: "Entraînement des troupes"
        case .academy: "Recherche de nouvelles unités"
        }
    }

    var defenseStrength: Int { self == .watchtower ? 2 : 0 }
    var storageIncrease: Int { self == .warehouse ? 500 : 0 }
}
