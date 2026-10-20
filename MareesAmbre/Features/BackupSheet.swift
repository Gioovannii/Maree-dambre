import SwiftUI
import UniformTypeIdentifiers

struct BackupSheet: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var document = GameBackupDocument()
    @State private var showsExport = false
    @State private var showsImport = false
    @State private var pendingData: Data?
    @State private var showsConfirmation = false
    @State private var showsError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(String(localized: "backup.explanation", defaultValue: "La partie est enregistrée sur cet appareil. Exportez-la vers Fichiers ou AirDrop, puis importez le fichier sur votre autre appareil. Le compte Apple ne synchronise pas encore la partie automatiquement."))
                    Button(String(localized: "backup.export", defaultValue: "Exporter ma partie"), systemImage: "square.and.arrow.up") {
                        do {
                            document = GameBackupDocument(data: try session.exportBackup())
                            showsExport = true
                        } catch { showsError = true }
                    }
                    .disabled(session.state.people == nil || session.hasUnreadableSave)
                }
                Section {
                    Button(String(localized: "backup.import", defaultValue: "Importer une partie"), systemImage: "square.and.arrow.down") { showsImport = true }
                    Text(String(localized: "backup.warning", defaultValue: "L’import remplace la partie de cet appareil après confirmation. Une copie locale de la sauvegarde précédente sera conservée. Les parties ne sont pas fusionnées."))
                        .font(.footnote)
                }
            }
            .navigationTitle(String(localized: "backup.title", defaultValue: "Sauvegarde"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "backup.close", defaultValue: "Fermer")) { dismiss() }
                }
            }
            .fileExporter(isPresented: $showsExport, document: document, contentType: .json, defaultFilename: "Ambre-sauvegarde") { result in
                if case .failure = result { showsError = true }
            }
            .fileImporter(isPresented: $showsImport, allowedContentTypes: [.json]) { result in
                do {
                    let url = try result.get()
                    let scoped = url.startAccessingSecurityScopedResource()
                    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                    let file = try FileHandle(forReadingFrom: url)
                    defer { try? file.close() }
                    let data = try file.read(upToCount: 8_000_001) ?? Data()
                    _ = try session.validateBackup(data)
                    pendingData = data
                    showsConfirmation = true
                } catch { showsError = true }
            }
            .alert(String(localized: "backup.confirm", defaultValue: "Remplacer la partie de cet appareil ?"), isPresented: $showsConfirmation) {
                Button(String(localized: "backup.restore", defaultValue: "Restaurer"), role: .destructive) {
                    guard let data = pendingData else { return }
                    do { try session.restoreBackup(data); dismiss() }
                    catch { showsError = true }
                    pendingData = nil
                }
                Button(String(localized: "backup.cancel", defaultValue: "Annuler"), role: .cancel) { pendingData = nil }
            }
            .alert(String(localized: "backup.error", defaultValue: "Impossible de lire, enregistrer ou restaurer ce fichier. Vérifiez qu’il s’agit d’une sauvegarde compatible de Marées d’Ambre."), isPresented: $showsError) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
