import SwiftUI
import TipKit

@main
struct MareesAmbreApp: App {
    @State private var session = VillageSession()
    @State private var raidReminders = RaidReminderController()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            GameView()
                .environment(session)
                .environment(raidReminders)
                .task {
                    try? Tips.configure()
                    await raidReminders.synchronize(attack: session.state.nextDomainBotAttackDate)
                }
                .onChange(of: session.state.nextDomainBotAttackDate) { _, date in
                    Task { await raidReminders.synchronize(attack: date) }
                }
                .onChange(of: scenePhase) { _, _ in
                    session.refreshAfterSceneChange()
                    Task { await raidReminders.synchronize(attack: session.state.nextDomainBotAttackDate) }
                }
        }
    }
}
