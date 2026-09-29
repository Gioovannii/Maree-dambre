import ActivityKit
import Foundation

struct ConstructionActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double
    }

    let buildingName: String
    let buildingSymbol: String
    let endsAt: Date
}

enum ConstructionActivityController {
    static func start(for job: ConstructionJob) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = ConstructionActivityAttributes(
            buildingName: job.kind.name,
            buildingSymbol: job.kind.symbol,
            endsAt: job.endsAt
        )
        let state = ConstructionActivityAttributes.ContentState(progress: 0)
        _ = try? Activity.request(attributes: attributes, content: ActivityContent(state: state, staleDate: job.endsAt), pushType: nil)
    }

    static func end() {
        let activities = Activity<ConstructionActivityAttributes>.activities
        Task {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
