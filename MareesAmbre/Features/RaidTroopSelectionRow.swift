import SwiftUI

struct RaidTroopSelectionRow: View {
    @Binding var selection: RaidTroopSelection
    let available: Int
    var accessibilityPrefix = "raid"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(selection.unit.name, systemImage: selection.unit.emblem)
                .font(.headline)
            ArmyUnitStatsView(unit: selection.unit)
            Stepper(value: $selection.count, in: 0...max(0, available)) {
                Text(String(localized: "screen.raid.sent_count", defaultValue: "Envoyées : \(String(selection.count))"))
            }
            .accessibilityLabel(String(localized: "screen.raid.assign_unit", defaultValue: "Engager : \(String(selection.unit.name))"))
            .accessibilityValue(String(localized: "screen.raid.assignment", defaultValue: "\(String(selection.count)) envoyées, \(String(max(0, available - selection.count))) au village"))
            .accessibilityIdentifier("\(accessibilityPrefix).units.\(selection.unit.rawValue)")
            Text(String(localized: "screen.raid.available_and_remaining", defaultValue: "Disponibles : \(String(available)) · Au village : \(String(max(0, available - selection.count)))"))
                .font(.footnote).foregroundStyle(Palette.muted)
        }
    }
}
