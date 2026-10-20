import CloudKit
import Foundation
import Observation

/// Explicit snapshots, never an automatic replacement of a local game.
@MainActor @Observable
final class CloudBackupController {
    private(set) var isBusy = false
    private(set) var isReady = false
    private(set) var data: Data?
    private(set) var savedAt: Date?
    private(set) var message: String?
    @ObservationIgnored private let container = CKContainer(identifier: "iCloud.com.giovanni.mareesambre")
    @ObservationIgnored private var record: CKRecord?
    @ObservationIgnored private var account: CKRecord.ID?
    private let identifier = CKRecord.ID(recordName: "current-domain")

    func refresh() async {
        guard !isBusy else { return }
        isBusy = true
        isReady = false
        data = nil
        savedAt = nil
        record = nil
        message = nil
        defer { isBusy = false }
        do {
            guard try await container.accountStatus() == .available else {
                message = String(localized: "cloud.signin", defaultValue: "Connectez-vous à iCloud dans les réglages de cet appareil pour retrouver vos sauvegardes.")
                return
            }
            account = try await container.userRecordID()
            do {
                let fetched = try await container.privateCloudDatabase.record(for: identifier)
                guard let asset = fetched["snapshot"] as? CKAsset, let url = asset.fileURL else {
                    throw CocoaError(.fileReadCorruptFile)
                }
                let handle = try FileHandle(forReadingFrom: url)
                defer { try? handle.close() }
                let bytes = try handle.read(upToCount: 8_000_001) ?? Data()
                guard bytes.count <= 8_000_000 else { throw CocoaError(.fileReadTooLarge) }
                data = bytes
                savedAt = fetched.modificationDate
                record = fetched
            } catch let error as CKError where error.code == .unknownItem {
                // A new account has no snapshot yet. Other errors must not be
                // interpreted as permission to replace an existing snapshot.
            }
            isReady = true
        } catch {
            message = String(localized: "cloud.unavailable", defaultValue: "iCloud est indisponible. Vérifiez la connexion ou réessayez plus tard. La partie locale est conservée.")
        }
    }

    func upload(_ bytes: Data) async {
        guard isReady, !isBusy, bytes.count <= 8_000_000 else { return }
        isBusy = true
        message = nil
        defer { isBusy = false }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        defer { try? FileManager.default.removeItem(at: url) }
        do {
            guard let account, try await container.userRecordID() == account else {
                throw CocoaError(.userCancelled)
            }
            try bytes.write(to: url, options: .atomic)
            let candidate = record?.copy() as? CKRecord ?? CKRecord(recordType: "DomainBackup", recordID: identifier)
            candidate["snapshot"] = CKAsset(fileURL: url)
            let result = try await container.privateCloudDatabase.modifyRecords(saving: [candidate], deleting: [],
                savePolicy: .ifServerRecordUnchanged, atomically: true)
            guard let outcome = result.saveResults[identifier] else { throw CocoaError(.fileWriteUnknown) }
            let saved = try outcome.get()
            record = saved
            data = bytes
            savedAt = saved.modificationDate
            message = String(localized: "cloud.saved", defaultValue: "Partie sauvegardée dans votre iCloud.")
        } catch {
            // Discard cached change tags; the user must reload and review the
            // cloud snapshot before retrying, including after an uncertain reply.
            isReady = false
            message = String(localized: "cloud.failed", defaultValue: "Envoi impossible ou sauvegarde modifiée depuis un autre appareil. Actualisez iCloud avant de réessayer. Aucun remplacement forcé n’a été effectué.")
        }
    }
}
