enum BuildingKind: String, Codable, CaseIterable, Identifiable {
    case hall, lumbermill, farm, amberWorks, watchtower, warehouse, warCourt, academy
    case market, forge, infirmary, expeditionQuay
    var id: Self { self }
    var requiredResourceSite: ResourceSiteKind? {
        switch self {
        case .lumbermill: .woodland
        case .farm: .cropland
        case .amberWorks: .amberVein
        default: nil
        }
    }
    static let constructible: [Self] = [.lumbermill, .farm, .amberWorks, .watchtower, .warehouse, .warCourt, .academy, .market, .forge, .infirmary, .expeditionQuay]
    static func constructible(in area: VillageMapMode) -> [Self] {
        constructible.filter { $0.area == area }
    }

    var area: VillageMapMode {
        switch self {
        case .hall, .lumbermill, .farm, .amberWorks, .watchtower, .warehouse, .warCourt, .academy, .market, .forge, .infirmary, .expeditionQuay: .townCenter
        }
    }

    func suits(_ terrain: Terrain) -> Bool {
        switch self {
        case .hall: false
        case .lumbermill, .farm, .amberWorks, .watchtower, .warehouse, .warCourt, .academy, .market, .forge, .infirmary: terrain == .meadow
        case .expeditionQuay: terrain == .sea
        }
    }
    var name: String {
        switch self {
        case .hall: String(localized: "domain.building_kind.watchers_hall", defaultValue: "Maison des Veilleurs")
        case .lumbermill: String(localized: "domain.building_kind.sawmill", defaultValue: "Scierie")
        case .farm: String(localized: "domain.building_kind.farm", defaultValue: "Ferme")
        case .amberWorks: String(localized: "domain.building_kind.amber_workshop", defaultValue: "Atelier d’ambre")
        case .watchtower: String(localized: "domain.building_kind.watchtower", defaultValue: "Tour de garde")
        case .warehouse: String(localized: "domain.building_kind.warehouse", defaultValue: "Entrepôt")
        case .warCourt: String(localized: "domain.building_kind.training_grounds", defaultValue: "Cour des armes")
        case .academy: String(localized: "domain.building_kind.academy", defaultValue: "Maison des savoirs")
        case .market: String(localized: "domain.building_kind.market", defaultValue: "Marché")
        case .forge: String(localized: "domain.building_kind.forge", defaultValue: "Forge")
        case .infirmary: String(localized: "domain.building_kind.infirmary", defaultValue: "Infirmerie")
        case .expeditionQuay: String(localized: "domain.building_kind.expedition_quay", defaultValue: "Quai d’expédition")
        }
    }
    var purpose: String {
        switch self {
        case .hall: String(localized: "domain.building_kind.the_heart_of_the_village_it_provides_your_first_resources_continuously", defaultValue: "Cœur du village : elle assure les premières ressources sans interruption.")
        case .lumbermill: String(localized: "domain.building_kind.turns_forest_timber_into_supplies_for_construction", defaultValue: "Transforme le bois de la forêt en réserves pour les chantiers.")
        case .farm: String(localized: "domain.building_kind.grows_food_to_support_the_village_s_growth", defaultValue: "Cultive des vivres pour soutenir la croissance du village.")
        case .amberWorks: String(localized: "domain.building_kind.extracts_and_crafts_amber_from_this_deposit", defaultValue: "Extrait et travaille l’ambre présent dans ce gisement.")
        case .watchtower: String(localized: "domain.building_kind.watchtower_purpose", defaultValue: "Poste de veille du village. Dans cette version, les factions n’attaquent pas votre village et la tour n’améliore pas vos expéditions.")
        case .warehouse: String(localized: "domain.building_kind.increases_the_amount_of_resources_the_village_can_store", defaultValue: "Augmente la quantité de ressources que le village peut conserver.")
        case .warCourt: String(localized: "domain.building_kind.trains_units_unlocked_at_the_academy", defaultValue: "Entraîne les unités débloquées par la Maison des savoirs.")
        case .academy: String(localized: "domain.building_kind.researches_doctrines_that_unlock_new_units", defaultValue: "Étudie les doctrines qui débloquent de nouvelles unités.")
        case .market: String(localized: "domain.building_kind.market_purpose", defaultValue: "Échange les surplus contre les ressources qui manquent au village.")
        case .forge: String(localized: "domain.building_kind.forge_purpose", defaultValue: "Améliore les armes de toutes les troupes, en trois recherches successives.")
        case .infirmary: String(localized: "domain.building_kind.infirmary_purpose", defaultValue: "Soigne les blessés et réduit les pertes des prochaines expéditions.")
        case .expeditionQuay: String(localized: "domain.building_kind.quay_purpose", defaultValue: "Organise le transport du butin des prochaines expéditions.")
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
        case .market: "Marche"
        case .forge: "Forge"
        case .infirmary: "Infirmerie"
        case .expeditionQuay: "QuaiExpedition"
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
        case .market: "basket.fill"
        case .forge: "hammer.fill"
        case .infirmary: "cross.case.fill"
        case .expeditionQuay: "sailboat.fill"
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
        case .market: Resources(wood: 40, amber: 10, provisions: 20)
        case .forge: Resources(wood: 60, amber: 25, provisions: 30)
        case .infirmary: Resources(wood: 50, amber: 20, provisions: 40)
        case .expeditionQuay: Resources(wood: 70, amber: 20, provisions: 35)
        }
    }
    var yield: Resources {
        switch self {
        case .hall: Resources(wood: 2, amber: 1, provisions: 2)
        case .lumbermill: Resources(wood: 8, amber: 0, provisions: 0)
        case .farm: Resources(wood: 0, amber: 0, provisions: 8)
        case .amberWorks: Resources(wood: 0, amber: 4, provisions: 0)
        case .watchtower, .warehouse, .warCourt, .academy, .market, .forge, .infirmary, .expeditionQuay: Resources(wood: 0, amber: 0, provisions: 0)
        }
    }
    var productionText: String {
        return switch self {
        case .hall: String(localized: "domain.building_kind.2_wood_1_amber_2_food_h", defaultValue: "+2 bois · +1 ambre · +2 vivres / h")
        case .lumbermill: String(localized: "domain.building_kind.8_wood_h", defaultValue: "+8 bois / h")
        case .farm: String(localized: "domain.building_kind.8_food_h", defaultValue: "+8 vivres / h")
        case .amberWorks: String(localized: "domain.building_kind.4_amber_h", defaultValue: "+4 ambre / h")
        case .watchtower: String(localized: "domain.building_kind.watchtower_effect", defaultValue: "Sans effet sur les combats actuels")
        case .warehouse: String(localized: "domain.building_kind.500_storage_capacity", defaultValue: "+500 de capacité de réserve")
        case .warCourt: String(localized: "domain.building_kind.troop_training", defaultValue: "Entraînement des troupes")
        case .academy: String(localized: "domain.building_kind.new_unit_research", defaultValue: "Recherche de nouvelles unités")
        case .market: String(localized: "domain.building_kind.market_effect", defaultValue: "Échanges locaux de ressources")
        case .forge: String(localized: "domain.building_kind.forge_effect", defaultValue: "+1 attaque par unité et par recherche · 3 niveaux")
        case .infirmary: String(localized: "domain.building_kind.infirmary_effect", defaultValue: "Pertes : 10 % en victoire, 35 % en défaite · 5 % avec un mage")
        case .expeditionQuay: String(localized: "domain.building_kind.quay_effect", defaultValue: "+25 % de transport · butin jusqu’à 90 par ressource")
        }
    }

    var defenseStrength: Int { self == .watchtower ? 2 : 0 }
    var storageIncrease: Int { self == .warehouse ? 500 : 0 }
}
