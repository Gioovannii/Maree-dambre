import SwiftUI

struct DomainObjectiveCard: View {
    let objective: DomainObjective
    let onContinue: (DomainObjective) -> Void

    private var title: String {
        switch objective.kind {
        case .colony: String(localized: "journey.colony.title", defaultValue: "Faire grandir la colonie")
        case .forge: String(localized: "journey.forge.title", defaultValue: "Renforcer votre arsenal")
        case .capital: String(localized: "journey.capital.title", defaultValue: "Préparer le troisième rivage")
        case .thirdVillage: String(localized: "journey.third.title", defaultValue: "Étendre votre domaine")
        case .established: String(localized: "journey.established.title", defaultValue: "Un domaine établi")
        }
    }

    private var detail: String {
        switch objective.kind {
        case .colony: String(localized: "journey.colony.body", defaultValue: "Dans votre première colonie, développez au niveau 3 un champ de chaque ressource. Une économie locale solide vous permettra de soutenir vos prochains projets.")
        case .forge: String(localized: "journey.forge.body", defaultValue: "Améliorez la forge de la capitale au niveau 3 pour préparer l’amélioration des armes de vos unités.")
        case .capital: String(localized: "journey.capital.body", defaultValue: "Préparez la capitale : cœur du village niveau 8, académie niveau 5, quai niveau 3 et entrepôt niveau 7.")
        case .thirdVillage: String(localized: "journey.third.body", defaultValue: "Préparez de nouveaux colons, rassemblez les ressources de fondation et choisissez votre troisième implantation. Un refuge offre une expansion à l’abri des raids.")
        case .established: String(localized: "journey.established.body", defaultValue: "Vos trois implantations sont établies. Vous pouvez poursuivre leur développement, améliorer vos armes et explorer les expéditions voisines.")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "journey.title", defaultValue: "L’essor du domaine"), systemImage: "flag.checkered")
                .font(.caption.bold()).foregroundStyle(Palette.amber)
            Text(title).font(.headline)
            Text(detail).font(.subheadline).foregroundStyle(Palette.muted)
            if objective.kind != .established {
                ProgressView(value: Double(objective.progress), total: Double(objective.total))
                    .accessibilityLabel(title)
                Button(String(localized: "journey.continue", defaultValue: "Poursuivre cet objectif"), systemImage: "arrow.right") {
                    onContinue(objective)
                }
                .buttonStyle(.bordered).frame(minHeight: 44)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.panel, in: .rect(cornerRadius: 20))
    }
}
