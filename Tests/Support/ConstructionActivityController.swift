// Session checks run on macOS, where ActivityKit is unavailable.
// The real iOS controller is compiled by the app build.
@MainActor
enum ConstructionActivityController {
    static func start(for job: ResourceUpgrade) {}
    static func start(for job: ConstructionJob) {}
    static func end() {}
}
