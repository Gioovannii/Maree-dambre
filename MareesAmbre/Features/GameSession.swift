import Foundation
import Observation

@MainActor @Observable
final class GameSession {
    private(set) var game: GameState
    var selectedID = 0
    private(set) var message = L10n.text("Votre archipel vous attend. Rien ne change en votre absence.", "Your archipelago awaits. Nothing changes while you are away.")
    private let storage = GameStorage()

    init() {
        let seed = WeeklyChallenge.seed(for: .now)
        game = GameState(seed: seed)
        do {
            if let saved = try storage.load(seed: seed) { game = saved }
        } catch {
            message = L10n.text("Sauvegarde illisible : aperçu neuf chargé. L’ancienne sauvegarde reste intacte jusqu’à votre prochaine action.", "Unreadable save: a fresh preview was loaded. Your previous save remains intact until your next action.")
        }
    }

    var selected: Island { game.islands.first(where: { $0.id == selectedID }) ?? game.islands[0] }

    func develop() {
        guard game.develop(selectedID) else { return }
        do {
            try storage.save(game)
            message = L10n.text("Port amélioré au niveau \(selected.portLevel). Progression enregistrée sur cet appareil.", "Harbor upgraded to level \(selected.portLevel). Progress saved on this device.")
        } catch {
            message = L10n.text("Amélioration active, mais la sauvegarde locale a échoué.", "Upgrade applied, but the local save failed.")
        }
    }
}
