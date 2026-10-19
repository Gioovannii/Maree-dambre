import SwiftUI

struct VillageGuideView: View {
    let people: People
    let step: VillageGuideStep
    @Binding var messages: [VillageGuideMessage]
    let onClose: () -> Void
    let onShowDestination: () -> Void
    @Environment(VillageSession.self) private var session

    static func portrait(for people: People) -> String {
        switch people {
        case .sauniers: "GuideMaelle"
        case .nacre: "GuideNerio"
        case .roseaux: "GuideSylve"
        }
    }

    private var name: String {
        switch people {
        case .sauniers: "Maëlle"
        case .nacre: "Nério"
        case .roseaux: "Sylve"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(Self.portrait(for: people))
                    .resizable().scaledToFill().frame(width: 44, height: 44, alignment: .top)
                    .clipShape(Circle()).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name).font(.headline).fontDesign(.serif)
                    Text(String(localized: "guide.local_advice", defaultValue: "Conseils du village"))
                        .font(.caption).foregroundStyle(Palette.muted)
                }
                Spacer(minLength: 0)
                Button(action: onClose) {
                    Image(systemName: "xmark").frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "guide.minimize", defaultValue: "Réduire la conversation"))
            }
            .padding(12)
            Divider().overlay(Palette.muted.opacity(0.3))
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        bubble(step.advice, isPlayer: false)
                        ForEach(messages) { message in
                            bubble(message.question, isPlayer: true)
                            bubble(message.answer, isPlayer: false)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            quickReply(String(localized: "guide.next_question", defaultValue: "Que faire ensuite ?"), answer: step.advice)
                            quickReply(String(localized: "guide.blocked_question", defaultValue: "Pourquoi je suis bloqué ?"), answer: blockerAdvice)
                            quickReply(String(localized: "guide.raid_question", defaultValue: "Comment préparer mon premier raid ?"), answer: VillageGuideStep.raid.advice)
                            Button(String(localized: "guide.show_me", defaultValue: "Montre-moi où aller"), action: onShowDestination)
                                .buttonStyle(.borderedProminent).foregroundStyle(Palette.ocean)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        Text(String(localized: "guide.chat_pending", defaultValue: "Chat libre Core AI à venir. Ces réponses suivent les règles du jeu."))
                            .font(.caption2).foregroundStyle(Palette.muted)
                        Color.clear.frame(height: 1).id("latest")
                    }
                    .padding(14)
                }
                .onChange(of: messages.last?.id) { _, _ in proxy.scrollTo("latest", anchor: .bottom) }
            }
        }
        .foregroundStyle(Palette.paper)
        .background(Palette.ocean, in: .rect(cornerRadius: 22))
        .overlay { RoundedRectangle(cornerRadius: 22).strokeBorder(Palette.amber.opacity(0.5)) }
        .clipShape(.rect(cornerRadius: 22))
        .tint(Palette.amber)
    }

    private var blockerAdvice: String {
        if session.state.construction != nil || session.state.resourceUpgrade != nil {
            return String(localized: "guide.blocker_construction", defaultValue: "Un chantier est en cours. Les champs et les bâtiments partagent ce chantier : attends sa fin ou examine son annulation avant d’en lancer un autre.")
        }
        return String(localized: "guide.blocker_general", defaultValue: "Vérifie le coût, la place dans l’entrepôt et les prérequis de l’action. Pour recruter, il faut rechercher l’unité puis l’entraîner à la Cour des armes. Un bouton grisé peut aussi indiquer qu’une tâche est déjà en cours.")
    }

    private func quickReply(_ question: String, answer: String) -> some View {
        Button(question) {
            if messages.count >= 8 { messages.removeFirst() }
            messages.append(VillageGuideMessage(question: question, answer: answer))
        }
        .buttonStyle(.bordered)
        .multilineTextAlignment(.leading)
    }

    private func bubble(_ text: String, isPlayer: Bool) -> some View {
        HStack {
            if isPlayer { Spacer(minLength: 24) }
            Text(text).font(.subheadline).fixedSize(horizontal: false, vertical: true).padding(12)
                .foregroundStyle(isPlayer ? Palette.ocean : Palette.paper)
                .background(isPlayer ? Palette.amber : Palette.panel, in: .rect(cornerRadius: 14))
                .accessibilityLabel((isPlayer ? String(localized: "guide.you", defaultValue: "Toi") : name) + ": " + text)
            if !isPlayer { Spacer(minLength: 24) }
        }
    }
}
