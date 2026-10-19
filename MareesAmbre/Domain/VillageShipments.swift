import Foundation

extension VillageState {
    var shipmentEscortCount: Int {
        guard let shipment, !shipment.escortReturned else { return 0 }
        return shipment.units.values.reduce(0, +)
    }

    func shipmentDuration(to destination: TileCoordinate) -> TimeInterval {
        60 + TimeInterval(location.distance(to: destination) * 10)
    }

    func canSendShipment(to destination: TileCoordinate, cargo: Resources, units: [ArmyUnit: Int]) -> Bool {
        guard people != nil, hasBuilding(.expeditionQuay), shipment == nil || shipment?.isComplete == true,
              destination != location, ownedLocations.contains(destination),
              [cargo.wood, cargo.amber, cargo.provisions].allSatisfy({ (0...999_999).contains($0) }),
              cargo.wood + cargo.amber + cargo.provisions > 0,
              canAffordExpansion(cargo), units.values.contains(where: { $0 > 0 }),
              units.allSatisfy({ $0.value >= 0 && $0.value <= availableArmy[$0.key, default: 0] }) else { return false }
        return cargo.wood + cargo.amber + cargo.provisions <= convoyCapacity(for: units)
    }

    @discardableResult
    mutating func sendShipment(to destination: TileCoordinate, cargo: Resources, units: [ArmyUnit: Int], now: Date = .now) -> Bool {
        guard canSendShipment(to: destination, cargo: cargo, units: units),
              now >= .distantPast, now <= .distantFuture else { return false }
        let escort = units.filter { $0.value > 0 }
        let duration = shipmentDuration(to: destination)
        let order = SettlementShipment(destination: destination, cargo: cargo, units: escort,
                                       transportBonusPercent: transportBonusPercent, departedAt: now,
                                       arrivesAt: now.addingTimeInterval(duration), returnsAt: now.addingTimeInterval(duration * 2))
        guard order.isValid else { return false }
        var troops = army ?? ArmyState()
        troops.unlockedUnits = unlockedUnits
        for (unit, count) in escort {
            troops.units[unit, default: 0] -= count
        }
        troops.units = troops.units.filter { $0.value > 0 }
        resources.wood -= cargo.wood
        resources.amber -= cargo.amber
        resources.provisions -= cargo.provisions
        army = troops
        shipment = order
        return true
    }

    /// Shared delivery ledger stays independent of which village the UI selects.
    mutating func settleShipments(now: Date) {
        var active = self
        active.otherVillages = nil
        var villages = [active] + (otherVillages ?? [])
        let sources = villages.indices.sorted {
            let lhs = villages[$0].location, rhs = villages[$1].location
            return lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
        }
        for source in sources {
            guard var order = villages[source].shipment, !order.isComplete,
                  let destination = villages.firstIndex(where: { $0.location == order.destination }) else { continue }
            if now >= order.arrivesAt {
                let pending = order.remaining
                let target = villages[destination]
                let wood = min(pending.wood, max(0, target.storageCapacity - target.resources.wood))
                let amber = min(pending.amber, max(0, target.storageCapacity - target.resources.amber))
                let food = min(pending.provisions, max(0, target.storageCapacity - target.resources.provisions))
                villages[destination].resources.wood += wood
                villages[destination].resources.amber += amber
                villages[destination].resources.provisions += food
                order.unloaded.wood += wood
                order.unloaded.amber += amber
                order.unloaded.provisions += food
            }
            if now >= order.returnsAt && !order.escortReturned {
                var troops = villages[source].army ?? ArmyState()
                for (unit, count) in order.units { troops.units[unit, default: 0] += count }
                villages[source].army = troops
                order.escortReturned = true
            }
            if order.unloaded == order.cargo && villages[source].shipment?.unloaded != order.cargo {
                villages[source].receiveMail(.shipment(order), key: "shipment.\(order.departedAt.timeIntervalSinceReferenceDate)", at: now)
            }
            villages[source].shipment = order
        }
        self = villages.removeFirst()
        otherVillages = villages.isEmpty ? nil : villages
    }
}
