import Foundation

func shipmentFixture(now: Date) -> VillageState {
    var village = VillageState(seed: 42)
    village.people = .sauniers
    village.lastProductionAt = now
    village.lastBotExpansionAt = now
    for kind in [BuildingKind.warehouse, .expeditionQuay, .warCourt] {
        let plot = VillageMapMode.townCenter.slots.first { village.buildings[$0] == nil && VillageState.canPlace(kind, at: $0) }!
        village.buildings[plot] = kind
    }
    village.buildingLevels = [.warehouse: 3]
    village.resources = Resources(wood: 1000, amber: 1000, provisions: 1000)
    village.army = ArmyState(units: [.tideguard: 100], unlockedUnits: [.tideguard])
    let target = village.suggestedSettlementSites(on: WorldMap(seed: 42)).first!
    var colony = VillageState(seed: 42)
    colony.people = village.people
    colony.settlementLocation = target
    colony.settlementRole = .production
    colony.settlementRefuge = village.isRefugeSite(target)
    colony.lastProductionAt = now
    colony.lastBotExpansionAt = now
    colony.resources = Resources(wood: 0, amber: 0, provisions: 0)
    village.otherVillages = [colony]
    return village
}

func checkShipments() throws {
    let now = Date(timeIntervalSince1970: 1_900_000_000)
    let world = WorldMap(seed: 42)
    var village = shipmentFixture(now: now)
    let target = village.otherVillages![0].location
    let cargo = Resources(wood: 40, amber: 20, provisions: 30)
    let before = village
    for invalid in [Resources(wood: -1, amber: 0, provisions: 0), Resources(wood: 0, amber: 0, provisions: 0),
                    Resources(wood: Int.max, amber: Int.max, provisions: Int.max), Resources(wood: 1001, amber: 0, provisions: 0)] {
        precondition(!village.sendShipment(to: target, cargo: invalid, units: [.tideguard: 5], now: now) && village == before)
    }
    precondition(!village.sendShipment(to: .home, cargo: cargo, units: [.tideguard: 5], now: now))
    precondition(!village.sendShipment(to: village.bots[0].capital, cargo: cargo, units: [.tideguard: 5], now: now))
    precondition(!village.sendShipment(to: target, cargo: cargo, units: [:], now: now))
    precondition(!village.sendShipment(to: target, cargo: cargo, units: [.tideguard: 1], now: now))
    precondition(!village.sendShipment(to: target, cargo: cargo, units: [.tideguard: 101], now: now))
    precondition(village.sendShipment(to: target, cargo: cargo, units: [.tideguard: 5], now: now))
    let order = village.shipment!
    precondition(order.isValid && village.shipmentEscortCount == 5 && village.availableArmy[.tideguard] == 95)
    precondition(village.resources == Resources(wood: 960, amber: 980, provisions: 970))
    precondition(!village.canTrain(.tideguard, count: 1), "Transporters still occupy the village army capacity")
    let departed = village
    precondition(!village.sendShipment(to: target, cargo: cargo, units: [.tideguard: 5], now: now) && village == departed)
    village.updateDomain(now: order.arrivesAt.addingTimeInterval(-1), on: world)
    precondition(village.shipment!.unloaded == Resources(wood: 0, amber: 0, provisions: 0))
    village.updateDomain(now: order.arrivesAt, on: world)
    precondition(village.shipment!.unloaded == cargo && !village.shipment!.escortReturned)
    precondition(village.allMail.filter { if case .shipment = $0.content { true } else { false } }.count == 1)
    precondition(village.otherVillages![0].resources.wood >= cargo.wood)
    precondition(village.availableArmy[.tideguard] == 95)
    precondition(village.switchSettlement(to: target))
    village.updateDomain(now: order.returnsAt, on: world)
    precondition(village.otherVillages![0].availableArmy[.tideguard] == 100)
    precondition(village.otherVillages![0].shipment?.isComplete == true)
    let finished = village
    village.updateDomain(now: order.returnsAt, on: world)
    precondition(village == finished, "Repeated clocks must not duplicate deliveries or soldiers")

    var full = shipmentFixture(now: now)
    full.otherVillages![0].resources = Resources(wood: 300, amber: 300, provisions: 300)
    let smallCargo = Resources(wood: 60, amber: 0, provisions: 0)
    precondition(full.sendShipment(to: target, cargo: smallCargo, units: [.tideguard: 5], now: now))
    let fullOrder = full.shipment!
    full.updateDomain(now: fullOrder.returnsAt, on: world)
    precondition(full.shipment!.escortReturned && full.shipment!.remaining == smallCargo)
    precondition(full.availableArmy[.tideguard] == 100)
    precondition(!full.canSendShipment(to: target, cargo: smallCargo, units: [.tideguard: 5]))
    precondition(full.switchSettlement(to: target))
    full.resources.wood -= 20
    full.updateDomain(now: fullOrder.returnsAt.addingTimeInterval(1), on: world)
    precondition(full.otherVillages![0].shipment!.remaining.wood == 40)
    precondition(full.resources.wood == 300)
    full.resources.wood -= 40
    full.updateDomain(now: fullOrder.returnsAt.addingTimeInterval(2), on: world)
    precondition(full.otherVillages![0].shipment!.isComplete)
    precondition(full.resources.wood == 300)
    precondition(full.switchSettlement(to: .home))
    precondition(full.canSendShipment(to: target, cargo: smallCargo, units: [.tideguard: 5]))

    // A single long offline interval must match stepping through arrival and return.
    var jumped = departed
    jumped.updateDomain(now: order.returnsAt.addingTimeInterval(7200), on: world)
    var stepped = departed
    stepped.updateDomain(now: order.arrivesAt, on: world)
    stepped.updateDomain(now: order.returnsAt, on: world)
    stepped.updateDomain(now: order.returnsAt.addingTimeInterval(7200), on: world)
    precondition(jumped == stepped, "Cargo must arrive before subsequent offline production fills the destination")

    let suite = "MareesAmbre.Shipment.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let storage = VillageStorage(defaults: defaults)
    try storage.save(departed)
    var restored = try storage.load(seed: 42, world: world, now: now)!
    restored.updateDomain(now: order.returnsAt, on: world)
    precondition(restored.shipment!.isComplete && restored.availableArmy[.tideguard] == 100)
    try storage.save(restored)
    let final = try storage.load(seed: 42, world: world, now: order.returnsAt)!
    precondition(final == restored)
    var corrupt = departed
    corrupt.shipment!.unloaded.wood = cargo.wood + 1
    try storage.save(corrupt)
    do {
        _ = try storage.load(seed: 42, world: world, now: now)
        preconditionFailure("Cargo duplication must be rejected")
    } catch { }
    corrupt = departed
    corrupt.shipment!.escortReturned = true
    try storage.save(corrupt)
    do {
        _ = try storage.load(seed: 42, world: world, now: now)
        preconditionFailure("Premature escort return must be rejected")
    } catch { }
    print("PASS: atomic supply departures, capacity, shared troops, independent delivery/return, storage escrow, offline chronology and save validation")
}
