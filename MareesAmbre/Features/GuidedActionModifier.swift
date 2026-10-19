import SwiftUI
import TipKit

struct GuidedActionModifier: ViewModifier {
    let step: VillageGuideStep
    var isTarget = true
    var anchor = "action"
    @Environment(VillageSession.self) private var session

    func body(content: Content) -> some View {
        content.popoverTip(session.guidedStep == step && isTarget && !session.state.hasCompletedGuide
                           ? VillageGuideTip(step: step, anchor: anchor) : nil)
    }
}
