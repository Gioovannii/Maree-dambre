import ActivityKit
import WidgetKit
import SwiftUI

struct ConstructionActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable { var progress: Double }
    let buildingName: String
    let buildingSymbol: String
    let endsAt: Date
}

struct ConstructionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ConstructionActivityAttributes.self) { context in
            HStack(spacing: 12) {
                Image(systemName: context.attributes.buildingSymbol)
                    .font(.title2.bold()).foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chantier en cours").font(.caption.bold()).textCase(.uppercase)
                    Text(context.attributes.buildingName).font(.headline)
                    ProgressView(timerInterval: Date.now...context.attributes.endsAt, countsDown: true)
                        .tint(.orange)
                }
                Spacer()
                Text(context.attributes.endsAt, style: .timer).font(.headline.monospacedDigit())
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
                    Text(context.attributes.endsAt, style: .timer).monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(timerInterval: Date.now...context.attributes.endsAt, countsDown: true)
                        .tint(.orange)
                }
            } compactLeading: {
                Image(systemName: context.attributes.buildingSymbol).foregroundStyle(.orange)
            } compactTrailing: {
                Text(context.attributes.endsAt, style: .timer).monospacedDigit()
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
