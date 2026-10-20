import SwiftUI

struct PeopleSpecialtyPanel: View {
    @Environment(VillageSession.self) private var session

    var body: some View {
        if let people = session.state.people {
            VStack(alignment: .leading, spacing: 8) {
                Label(people.specialtyTitle, systemImage: people.emblem)
                    .font(.headline)
                Text(people.specialtyDescription)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                Label(session.state.hasBuilding(people.specialtyBuilding)
                      ? String(localized: "people.specialty.active", defaultValue: "Spécialité active dans ce village")
                      : String(localized: "people.specialty.locked", defaultValue: "Construisez le bâtiment associé pour activer cette spécialité"),
                      systemImage: session.state.hasBuilding(people.specialtyBuilding) ? "checkmark.circle" : "lock")
                    .font(.footnote)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.panel, in: .rect(cornerRadius: 16))
        }
    }
}
