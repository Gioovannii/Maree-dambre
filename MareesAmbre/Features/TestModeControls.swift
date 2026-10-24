import SwiftUI

struct TestModeControls: View {
    @Environment(VillageSession.self) private var session
    @State private var confirmsNewCopy = false
    @State private var showsError = false

    var body: some View {
        Section(String(localized: "test.mode.title", defaultValue: "Copie de test")) {
            if session.isTestMode {
                Label(String(localized: "test.mode.active", defaultValue: "Vous jouez sur une copie de test"), systemImage: "flask.fill")
                Button(String(localized: "debug.time.minute", defaultValue: "Avancer d’une minute")) { session.advanceTestTime(by: 60) }
                Button(String(localized: "debug.time.hour", defaultValue: "Avancer d’une heure")) { session.advanceTestTime(by: 3600) }
                Button(String(localized: "debug.time.day", defaultValue: "Avancer d’un jour")) { session.advanceTestTime(by: 86400) }
                Button(String(localized: "test.mode.leave", defaultValue: "Revenir à ma partie normale")) {
                    do { try session.leaveTestGame() } catch { showsError = true }
                }
                Text(String(localized: "test.mode.isolated", defaultValue: "Cette copie reste sur cet appareil. Ses ressources et ses progrès ne sont pas transférables. La partie normale continue à son rythme habituel."))
                    .font(.footnote)
            } else {
                if session.hasSavedTestGame {
                    Button(String(localized: "test.mode.resume", defaultValue: "Reprendre ma copie de test")) {
                        do { try session.resumeTestGame() } catch { showsError = true }
                    }
                }
                Button(String(localized: "test.mode.create", defaultValue: "Créer une copie de test de cette partie")) { confirmsNewCopy = true }
                    .disabled(session.hasUnreadableSave || session.state.people == nil)
                Text(String(localized: "test.mode.help", defaultValue: "Essayez les améliorations et avancez le temps sur une copie séparée. Vous retrouverez votre partie normale en quittant le test ou en relançant l’app."))
                    .font(.footnote)
            }
        }
        .alert(String(localized: "test.mode.confirm", defaultValue: "Créer une nouvelle copie de test ?"), isPresented: $confirmsNewCopy) {
            Button(String(localized: "test.mode.create_short", defaultValue: "Créer la copie")) {
                do { try session.startTestGame() } catch { showsError = true }
            }
            Button(String(localized: "backup.cancel", defaultValue: "Annuler"), role: .cancel) {}
        } message: {
            Text(String(localized: "test.mode.replace", defaultValue: "Votre partie normale est conservée. Si une ancienne copie de test existe, elle sera remplacée."))
        }
        .alert(String(localized: "test.mode.error", defaultValue: "Impossible de changer de partie. Les sauvegardes existantes sont conservées."), isPresented: $showsError) {
            Button("OK", role: .cancel) {}
        }
    }
}
