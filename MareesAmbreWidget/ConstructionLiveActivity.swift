import ActivityKit
import WidgetKit
import SwiftUI

struct ConstructionActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable { var progress: Double }
    let buildingName: String
    let buildingSymbol: String
    let endsAt: Date
    var startedAt: Date?
}

struct ConstructionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ConstructionActivityAttributes.self) { context in
            HStack(spacing: 12) {
                Image(systemName: context.attributes.buildingSymbol)
                    .font(.title2.bold()).foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.isStale || context.attributes.endsAt <= .now ? String(localized: "widget.construction_live_activity.construction_complete", defaultValue: "Chantier terminé") : String(localized: "widget.construction_live_activity.construction_in_progress", defaultValue: "Chantier en cours")).font(.caption.bold()).textCase(.uppercase)
                    Text(context.attributes.buildingName).font(.headline)
                    ProgressView(timerInterval: min(context.attributes.startedAt ?? context.attributes.endsAt.addingTimeInterval(-60), context.attributes.endsAt)...context.attributes.endsAt, countsDown: false)
                        .tint(.orange)
                }
                Spacer()
                ConstructionCountdown(endsAt: context.attributes.endsAt, isStale: context.isStale).font(.headline.monospacedDigit())
            }
            .padding(16)
            .activityBackgroundTint(Color(red: 0.04, green: 0.15, blue: 0.18))
            .activitySystemActionForegroundColor(.orange)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.buildingSymbol).foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.buildingName).font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ConstructionCountdown(endsAt: context.attributes.endsAt, isStale: context.isStale).monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(timerInterval: min(context.attributes.startedAt ?? context.attributes.endsAt.addingTimeInterval(-60), context.attributes.endsAt)...context.attributes.endsAt, countsDown: false)
                        .tint(.orange)
                }
            } compactLeading: {
                Image(systemName: context.attributes.buildingSymbol).foregroundStyle(.orange)
            } compactTrailing: {
                ConstructionCountdown(endsAt: context.attributes.endsAt, isStale: context.isStale).monospacedDigit()
                    .frame(width: 48)
            } minimal: {
                Image(systemName: "hammer.fill").foregroundStyle(.orange)
            }
        }
    }
}

@main
struct MareesAmbreWidgetBundle: WidgetBundle {
    var body: some Widget { ConstructionLiveActivity() }
}
