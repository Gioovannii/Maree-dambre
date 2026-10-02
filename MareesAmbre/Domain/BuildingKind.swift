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
        case .hall: L10n.text("Maison des Veilleurs", "Watchers’ Hall")
        case .lumbermill: L10n.text("Scierie", "Sawmill")
        case .farm: L10n.text("Ferme", "Farm")
        case .amberWorks: L10n.text("Atelier d’ambre", "Amber Workshop")
        case .watchtower: L10n.text("Tour de garde", "Watchtower")
        case .warehouse: L10n.text("Entrepôt", "Warehouse")
        case .warCourt: L10n.text("Cour des armes", "Training Grounds")
        case .academy: L10n.text("Maison des savoirs", "Academy")
        }
    }
    var purpose: String {
        switch self {
        case .hall: L10n.text("Cœur du village : elle assure les premières ressources sans interruption.", "The heart of the village. It provides your first resources continuously.")
        case .lumbermill: L10n.text("Transforme le bois de la forêt en réserves pour les chantiers.", "Turns forest timber into supplies for construction.")
        case .farm: L10n.text("Cultive des vivres pour soutenir la croissance du village.", "Grows food to support the village’s growth.")
        case .amberWorks: L10n.text("Extrait et travaille l’ambre présent dans ce gisement.", "Extracts and crafts amber from this deposit.")
        case .watchtower: L10n.text("Renforce la défense automatique du village.", "Strengthens the village’s automatic defense.")
        case .warehouse: L10n.text("Augmente la quantité de ressources que le village peut conserver.", "Increases the amount of resources the village can store.")
        case .warCourt: L10n.text("Entraîne les unités débloquées par la Maison des savoirs.", "Trains units unlocked at the Academy.")
        case .academy: L10n.text("Étudie les doctrines qui débloquent de nouvelles unités.", "Researches doctrines that unlock new units.")
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
        case .hall: L10n.text("+2 bois · +1 ambre · +2 vivres / h", "+2 wood · +1 amber · +2 food / h")
        case .lumbermill: L10n.text("+8 bois / h", "+8 wood / h")
        case .farm: L10n.text("+8 vivres / h", "+8 food / h")
        case .amberWorks: L10n.text("+4 ambre / h", "+4 amber / h")
        case .watchtower: L10n.text("+2 défense automatique", "+2 automatic defense")
        case .warehouse: L10n.text("+500 de capacité de réserve", "+500 storage capacity")
        case .warCourt: L10n.text("Entraînement des troupes", "Troop training")
        case .academy: L10n.text("Recherche de nouvelles unités", "New unit research")
        }
    }

    var defenseStrength: Int { self == .watchtower ? 2 : 0 }
    var storageIncrease: Int { self == .warehouse ? 500 : 0 }
}
