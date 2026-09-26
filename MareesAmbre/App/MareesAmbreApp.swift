import SwiftUI

@main
struct MareesAmbreApp: App {
    @State private var session = VillageSession()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            GameView()
                .environment(session)
                .onChange(of: scenePhase) { _, _ in session.refreshAfterSceneChange() }
        }
    }
}
