import SwiftUI
import TipKit

@main
struct MareesAmbreApp: App {
    @State private var session = VillageSession()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            GameView()
                .environment(session)
                .task { try? Tips.configure() }
                .onChange(of: scenePhase) { _, _ in session.refreshAfterSceneChange() }
        }
    }
}
