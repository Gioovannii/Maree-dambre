import SwiftUI

struct BackupRestoreReview: View {
    let local: VillageState
    let incoming: VillageStorage.BackupPreview
    let onRestore: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "backup.review.local", defaultValue: "Sur cet appareil")) {
                    summary(local)
                }
                Section(String(localized: "backup.review.incoming", defaultValue: "Partie à restaurer")) {
                    summary(incoming.village)
                    LabeledContent(String(localized: "backup.review.exported", defaultValue: "Exportée le")) {
                        Text(incoming.savedAt, format: .dateTime.day().month().year().hour().minute())
                    }
                }
                Section {
                    Text(String(localized: "backup.warning", defaultValue: "L’import remplace la partie de cet appareil après confirmation. Une copie locale de la sauvegarde précédente sera conservée. Les parties ne sont pas fusionnées."))
                        .font(.footnote)
                    Button(String(localized: "backup.review.replace", defaultValue: "Remplacer par cette partie"), role: .destructive, action: onRestore)
                }
            }
            .navigationTitle(String(localized: "backup.review.title", defaultValue: "Vérifier la sauvegarde"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "backup.cancel", defaultValue: "Annuler")) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func summary(_ state: VillageState) -> some View {
        let villages = [state] + (state.otherVillages ?? [])
        if let people = state.people {
            LabeledContent(String(localized: "backup.review.people", defaultValue: "Peuple"), value: people.name)
            metric(String(localized: "backup.review.villages", defaultValue: "Villages"), value: villages.count)
            metric(String(localized: "backup.review.buildings", defaultValue: "Bâtiments construits"), value: villages.reduce(0) { $0 + $1.buildings.count })
            metric(String(localized: "backup.review.fields", defaultValue: "Champs développés"), value: villages.reduce(0) { $0 + ($1.resourceLevels ?? [:]).values.filter { $0 > 0 }.count })
            metric(String(localized: "backup.review.building_levels", defaultValue: "Niveaux de bâtiments cumulés"), value: villages.reduce(0) { sum, village in
                sum + village.buildings.values.reduce(0) { $0 + village.buildingLevel($1) }
            })
            metric(String(localized: "backup.review.field_levels", defaultValue: "Niveaux de champs cumulés"), value: villages.reduce(0) { $0 + ($1.resourceLevels ?? [:]).values.reduce(0, +) })
            if let hero = state.hero {
                metric(String(localized: "backup.review.hero", defaultValue: "Niveau du héros"), value: hero.level)
            }
        } else {
            Text(String(localized: "backup.review.empty", defaultValue: "Aucune partie commencée"))
        }
    }

    private func metric(_ title: String, value: Int) -> some View {
        LabeledContent(title) { Text(value, format: .number) }
    }
}
