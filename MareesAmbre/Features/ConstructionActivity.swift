import ActivityKit
import Foundation

struct ConstructionActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double
    }

    let buildingName: String
    let buildingSymbol: String
    let endsAt: Date
    var startedAt: Date?
}

enum ConstructionActivityController {
    static func start(for job: ResourceUpgrade) {
        guard let kind = ResourceSiteKind.at(job.plot) else { return }
        start(name: L10n.text("\(kind.name) · Niveau \(job.targetLevel)", "\(kind.name) · Level \(job.targetLevel)"), symbol: kind.symbol,
              startedAt: job.startedAt, endsAt: job.endsAt)
    }

    static func start(for job: ConstructionJob) {
        start(name: job.kind.name, symbol: job.kind.symbol, startedAt: job.startedAt, endsAt: job.endsAt)
    }

    private static func start(name: String, symbol: String, startedAt: Date, endsAt: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = ConstructionActivityAttributes(
            buildingName: name,
            buildingSymbol: symbol,
            endsAt: endsAt,
            startedAt: startedAt
        )
        let state = ConstructionActivityAttributes.ContentState(progress: 0)
        _ = try? Activity.request(attributes: attributes, content: ActivityContent(state: state, staleDate: endsAt), pushType: nil)
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
