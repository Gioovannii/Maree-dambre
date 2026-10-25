import SwiftUI

struct PeopleSpecialtyPanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        if let people = session.state.people {
            VStack(alignment: .leading, spacing: 8) {
                Label(people.specialtyTitle, systemImage: people.emblem)
                    .font(.headline)
                Text(people.playStyle).font(.caption.bold()).foregroundStyle(Palette.amber)
                Text(people.specialtyDescription)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                Label(people.specialtyBuilding.name, systemImage: people.specialtyBuilding.symbol)
                    .font(.subheadline.bold())
                if session.state.hasBuilding(people.specialtyBuilding) {
                    Text(people.specialtyEffect(at: session.state.buildingLevel(people.specialtyBuilding)))
                        .font(.footnote)
                        .foregroundStyle(Palette.amber)
                }
                Label(session.state.hasBuilding(people.specialtyBuilding)
                      ? String(localized: "people.specialty.active", defaultValue: "Spécialité active dans ce village")
                      : String(localized: "people.specialty.locked", defaultValue: "Construisez le bâtiment associé pour activer cette spécialité"),
                      systemImage: session.state.hasBuilding(people.specialtyBuilding) ? "checkmark.circle" : "lock")
                    .font(.footnote)
                DisclosureGroup(String(localized: "people.tactics.title", defaultValue: "Comment jouer ce peuple")) {
                    Text(people.tacticalAdvice).font(.subheadline).foregroundStyle(Palette.muted)
                        .padding(.top, 8)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 16))
        }
    }
}
