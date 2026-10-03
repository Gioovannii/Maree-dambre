import Foundation
import Observation

@MainActor @Observable
final class GameSession {
    private(set) var game: GameState
    var selectedID = 0
    private(set) var message = String(localized: "screen.game_session.your_archipelago_awaits_nothing_changes_while_you_are_away", defaultValue: "Votre archipel vous attend. Rien ne change en votre absence.")
    private let storage = GameStorage()

    init() {
        let seed = WeeklyChallenge.seed(for: .now)
        game = GameState(seed: seed)
        do {
            if let saved = try storage.load(seed: seed) { game = saved }
        } catch {
            message = String(localized: "screen.game_session.unreadable_save_a_fresh_preview_was_loaded_your_previous_save_remains_intact_until_yo", defaultValue: "Sauvegarde illisible : aperçu neuf chargé. L’ancienne sauvegarde reste intacte jusqu’à votre prochaine action.")
        }
    }

    var selected: Island { game.islands.first(where: { $0.id == selectedID }) ?? game.islands[0] }

    func develop() {
        guard game.develop(selectedID) else { return }
        do {
            try storage.save(game)
            message = String(localized: "screen.game_session.harbor_upgraded_to_level_value_progress_saved_on_this_device", defaultValue: "Port amélioré au niveau \(String(selected.portLevel)). Progression enregistrée sur cet appareil.")
        } catch {
            message = String(localized: "screen.game_session.upgrade_applied_but_the_local_save_failed", defaultValue: "Amélioration active, mais la sauvegarde locale a échoué.")
        }
    }
}
