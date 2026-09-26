import Foundation
import Observation

@MainActor @Observable
final class GameSession {
    private(set) var game: GameState
    var selectedID = 0
    private(set) var message = "Votre archipel vous attend. Rien ne change en votre absence."
    private let storage = GameStorage()

    init() {
        let seed = WeeklyChallenge.seed(for: .now)
        game = GameState(seed: seed)
        do {
            if let saved = try storage.load(seed: seed) { game = saved }
        } catch {
            message = "Sauvegarde illisible : aperçu neuf chargé. L’ancienne sauvegarde reste intacte jusqu’à votre prochaine action."
        }
    }

    var selected: Island { game.islands.first(where: { $0.id == selectedID }) ?? game.islands[0] }

    func develop() {
        guard game.develop(selectedID) else { return }
        do {
            try storage.save(game)
            message = "Port amélioré au niveau \(selected.portLevel). Progression enregistrée sur cet appareil."
        } catch {
            message = "Amélioration active, mais la sauvegarde locale a échoué."
        }
    }
}
