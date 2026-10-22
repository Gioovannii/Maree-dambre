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
    @State private var cloud = CloudBackupController()
    @State private var showsCloudConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                #if DEBUG
                Section(String(localized: "debug.time.title", defaultValue: "Mode test — avancer le temps")) {
                    Button(String(localized: "debug.time.minute", defaultValue: "Avancer d’une minute")) { session.advanceTestTime(by: 60) }
                    Button(String(localized: "debug.time.hour", defaultValue: "Avancer d’une heure")) { session.advanceTestTime(by: 3600) }
                    Button(String(localized: "debug.time.day", defaultValue: "Avancer d’un jour")) { session.advanceTestTime(by: 86400) }
                    Text(String(localized: "debug.time.help", defaultValue: "Fait avancer la partie actuelle : production, travaux, voyages et attaques. Réservé au développement."))
                        .font(.footnote)
                }
                #endif
                Section("iCloud") {
                    if cloud.isBusy { ProgressView() }
                    if let date = cloud.savedAt {
                        Text(date, format: .dateTime.day().month().year().hour().minute())
                    }
                    if let message = cloud.message { Text(message).font(.footnote) }
                    Button(String(localized: "cloud.refresh", defaultValue: "Actualiser iCloud")) {
                        Task { await cloud.refresh() }
                    }
                    .disabled(cloud.isBusy)
                    Button(String(localized: "cloud.upload", defaultValue: "Sauvegarder cette partie dans iCloud")) {
                        showsCloudConfirmation = true
                    }
                    .disabled(!cloud.isReady || cloud.isBusy || session.state.people == nil || session.hasUnreadableSave)
                    Button(String(localized: "cloud.restore", defaultValue: "Restaurer la partie iCloud")) {
                        guard let data = cloud.data else { return }
                        do {
                            _ = try session.validateBackup(data)
                            pendingData = data
                            showsConfirmation = true
                        } catch { showsError = true }
                    }
                    .disabled(!cloud.isReady || cloud.isBusy || cloud.data == nil)
                    Text(String(localized: "cloud.explanation", defaultValue: "L’envoi et la restauration sont manuels. Sur l’appareil où se trouve votre progression, envoyez-la dans iCloud. Sur l’autre appareil, actualisez puis restaurez-la. Les parties ne sont pas fusionnées."))
                        .font(.footnote)
                }
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
            .task { await cloud.refresh() }
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
            .alert(String(localized: "cloud.confirm", defaultValue: "Enregistrer cette partie dans iCloud ?"), isPresented: $showsCloudConfirmation) {
                Button(String(localized: "cloud.upload", defaultValue: "Sauvegarder cette partie dans iCloud")) {
                    do {
                        let data = try session.exportBackup()
                        Task { await cloud.upload(data) }
                    } catch { showsError = true }
                }
                Button(String(localized: "backup.cancel", defaultValue: "Annuler"), role: .cancel) {}
            } message: {
                Text(String(localized: "cloud.replace", defaultValue: "Cela remplace la sauvegarde iCloud actuellement affichée par la partie de cet appareil. Vos autres appareils ne seront pas modifiés automatiquement."))
            }
        }
    }
}
