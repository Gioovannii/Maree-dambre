// Session checks run on macOS, where ActivityKit is unavailable.
// The real iOS controller is compiled by the app build.
@MainActor
enum ConstructionActivityController {
    private(set) static var starts = 0
    private(set) static var ends = 0
    static func start(for job: ResourceUpgrade) { starts += 1 }
    static func start(for job: ConstructionJob) { starts += 1 }
    static func end() { ends += 1 }
}
