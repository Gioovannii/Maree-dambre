import SwiftUI

/// A bounded countdown never turns into elapsed time after completion.
struct ConstructionCountdown: View {
    let endsAt: Date
    let isStale: Bool

    var body: some View {
        if isStale || endsAt <= .now {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .accessibilityLabel(L10n.text("Chantier terminé", "Construction complete"))
        } else {
            Text(timerInterval: min(Date.now, endsAt)...endsAt, countsDown: true, showsHours: false)
                .monospacedDigit()
        }
    }
}
