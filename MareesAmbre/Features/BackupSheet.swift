import SwiftUI
import UniformTypeIdentifiers

struct BackupSheet: View {
    @Environment(VillageSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var document = GameBackupDocument()
    @State private var showsExport = false
    @State private var showsImport = false
    @State private var pendingPreview: VillageStorage.BackupPreview?
    @State private var pendingData: Data?
    @State private var pendingSource: VillageStorage.BackupSource = .file
    @State private var showsError = false
    @State private var restoreFailed = false
    @State private var cloud = CloudBackupController()
    @State private var showsCloudConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                if session.allowsTestTimeControls || session.isTestMode { TestModeControls() }
                if session.state.progressionOrigin == .importedFile {
                    Section {
                        Label(String(localized: "backup.imported_source", defaultValue: "Partie issue d’un import de fichier."), systemImage: "doc.badge.ellipsis")
                            .font(.footnote)
                    }
                }
                Group {
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
                                pendingPreview = try session.previewBackup(data)
                                pendingData = data
                                pendingSource = .iCloud
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
                        Text(String(localized: "backup.auth.notice", defaultValue: "Seuls les exports authentifiés par l’app sont acceptés. Les fichiers modifiés et les anciens exports non authentifiés sont refusés : réexportez votre partie depuis l’appareil d’origine. Sur l’autre appareil, activez le même compte Apple et le Trousseau iCloud pour retrouver la clé de vérification."))
                            .font(.footnote)
                        Button(String(localized: "backup.import", defaultValue: "Importer une partie"), systemImage: "square.and.arrow.down") { showsImport = true }
                        Text(String(localized: "backup.warning", defaultValue: "L’import remplace la partie de cet appareil après confirmation. Une copie locale de la sauvegarde précédente sera conservée. Les parties ne sont pas fusionnées."))
                            .font(.footnote)
                    }
                }
                .disabled(session.isTestMode)
            }
            .navigationTitle(String(localized: "backup.title", defaultValue: "Sauvegarde"))
            .task {
                await session.refreshTestBuildAccess()
                if !session.isTestMode { await cloud.refresh() }
                if ProcessInfo.processInfo.arguments.contains("--ui-snapshot"),
                   ProcessInfo.processInfo.arguments.contains("--snapshot-backup-review") {
                    var incoming = session.state
                    incoming.people = .nacre
                    incoming.resourceLevels = [0: 3, 2: 3, 4: 3]
                    pendingPreview = VillageStorage.BackupPreview(village: incoming,
                        savedAt: Date(timeIntervalSince1970: 1_800_000_000))
                }
            }
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
                    pendingPreview = try session.previewBackup(data)
                    pendingData = data
                    pendingSource = .file
                } catch { showsError = true }
            }
            .sheet(item: $pendingPreview, onDismiss: {
                pendingData = nil
                pendingPreview = nil
                if restoreFailed {
                    restoreFailed = false
                    showsError = true
                }
            }) { preview in
                BackupRestoreReview(local: session.state, incoming: preview) {
                    guard let data = pendingData else { return }
                    do {
                        try session.restoreBackup(data, source: pendingSource)
                        pendingPreview = nil
                        dismiss()
                    } catch {
                        restoreFailed = true
                        pendingPreview = nil
                    }
                }
            }
            .alert(String(localized: "backup.auth.error", defaultValue: "Impossible de vérifier ou de restaurer cette sauvegarde. Utilisez un nouvel export de l’app, sans le modifier. Pour un transfert, vérifiez la synchronisation du Trousseau iCloud. Votre partie locale est conservée."), isPresented: $showsError) {
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
