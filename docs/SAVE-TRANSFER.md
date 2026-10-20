# Portable save transfer

Backup is available from the header and from the new-game screen. Export produces
a JSON document containing the whole selected domain, including other settlements,
hero, troops, mail and in-flight jobs. Store the document in Files and transfer it
to the other device, then import and confirm replacement there.

This is an explicit snapshot transfer, not Apple-account or iCloud synchronization.
Progress made independently on two devices is not merged. Export the device with
the desired progress and import on the destination before continuing play there.

Imports are limited to 8 MB and format version 1. They use the existing complete
save validation and migration in isolated storage before touching live data.
Confirmation validates again, preserves the active save and any existing save
with the incoming seed, and installs the imported domain. Copies are retained in
local defaults under `village.beforeRestore.*`; there is no recovery browser yet.
Offline progress then follows the same chronological processing as a normal launch.

## Private iCloud snapshots

The backup sheet can explicitly upload and restore a CloudKit snapshot using the
device's iCloud account. No Game Center login is used. Upload requires a successful
refresh, confirmation, and an unchanged server record change tag. A concurrent
write or uncertain response disables further uploads until another refresh.
Restoring uses the same isolated validation and local recovery-copy flow as files.
No automatic upload, local replacement, or game-state merge occurs.

Container: `iCloud.com.giovanni.mareesambre`, private default database.
Record type: `DomainBackup`; record ID: `current-domain`; field `snapshot`: Asset.
Only the app target needs CloudKit entitlements; the widget remains local.

Before TestFlight use, ensure this record type and Asset field exist in the
container's development schema, then deploy the schema to Production in CloudKit
Console. Development and Production backups are separate. A successful signed
build verifies signing, not availability of the Production schema or end-to-end
transfer. Do not claim cloud recovery is verified until the following passes:

1. On iPhone, upload a known domain and check success and its timestamp.
2. On iPad with the same iCloud account, refresh, restore and compare villages,
   armies, hero, mailbox and in-flight jobs; relaunch both devices.
3. Refresh on both devices, upload a changed game on one, then upload on the
   other without refreshing. The stale upload must fail rather than overwrite.
4. Test signed-out iCloud, no connection and a corrupt snapshot. Local progress
   must remain intact, and file export/import must stay available.

Automatic synchronization and recovery from an erased device without a previously
uploaded snapshot remain separate work. Existing TestFlight builds cannot upload
their progress until updated to a build containing this feature.

Reference: [Apple CloudKit optimistic concurrency](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation/recordsavepolicy/ifserverrecordunchanged).
