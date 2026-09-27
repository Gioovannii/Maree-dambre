import Foundation

/// Deterministic snapshot of the two map layouts.
/// This keeps visual anchors reviewable even when a simulator is unavailable.
@main
struct LayoutSnapshotChecks {
    static func main() {
        let town = VillageMapMode.townCenter
        let points = town.slots.map(town.mapPoint(for:))

        precondition(points.count == Set(points.map { "\($0.x),\($0.y)" }).count,
                     "Centre snapshot contains overlapping slots")
        precondition(points.allSatisfy { (0.08...0.92).contains($0.x) && (0.15...0.75).contains($0.y) },
                     "Centre snapshot contains an off-map slot")
        for (index, a) in points.enumerated() {
            for b in points.dropFirst(index + 1) {
                let distance = hypot((a.x - b.x) * 390, (a.y - b.y) * 840)
                precondition(distance >= 44, "Centre snapshot has overlapping touch targets")
            }
        }

        let hall = town.mapPoint(for: 12)
        precondition(abs(hall.x - 0.50) < 0.001 && abs(hall.y - 0.47) < 0.001,
                     "Centre hall moved away from the focal point")

        let resource = VillageMapMode.resourceFields
        precondition(resource.slots.count == 10, "Resource snapshot changed its slot count")
        print("PASS: settlement layout snapshot — \(town.slots.count) equal centre slots, hall centred")
    }
}
