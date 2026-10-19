import SwiftUI
import TipKit

struct VillageGuideTip: Tip {
    let step: VillageGuideStep
    var anchor = "action"
    var id: String { "village-guide.\(step.rawValue).\(anchor)" }
    var title: Text { Text(String(localized: "guide.tip_title", defaultValue: "Ta prochaine étape")) }
    var message: Text? { Text(String(localized: "guide.precise_action", defaultValue: "Voici la commande de ton objectif. Vérifie ses conditions, puis touche-la pour continuer.")) }
}
