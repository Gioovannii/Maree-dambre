# Isolated test games

The development and verified TestFlight builds can create a disposable copy of the current village from Settings → Backup → Test copy. Time controls affect this copy only. Creating another copy replaces the active test copy, not the normal game. A saved test can be resumed, and leaving the test or restarting the app opens normal play.

## Storage and provenance

Normal save keys remain unchanged. The test slot uses the `testMode.` prefix with a separate active seed. Gameplay, colony switching and offline ticks write to whichever slot is active. A test copy carries `progressionOrigin = test`; normal storage and backup validation reject that origin. The test slot cannot export a file, upload to iCloud or restore a normal game. The session enforces these restrictions as well as disabling the relevant buttons.

Provenance is domain-wide and follows the selected village. File imports are marked `importedFile` regardless of the payload's claimed origin. An iCloud restore preserves existing provenance, so uploading an imported game does not erase that marker. Legacy saves without provenance remain playable. Missing provenance is not proof of integrity.

Test actions do not start or stop construction Live Activities. Raid reminders continue to use the normal game's deadline; reminders cannot be enabled or disabled from a test copy. Production and combat remain visible in the copy so they can be exercised without replacing real notification schedules.

## Verification

`sh Scripts/check-session.sh` compiles the debug path and checks normal-save bytes, independent active seeds, accelerated construction, rejected invalid time intervals, village switching, restart behavior, resume, recreation, Live Activity calls, reminder deadlines, blocked exports/restores and file-import provenance through an iCloud round trip. These are isolated local tests and do not contact CloudKit.

Capture the controls with `SNAPSHOT_SCREEN=testMode zsh Scripts/check-ui-snapshots.sh capture`. Snapshot scenarios use demo data and do not write a real game. Also compile Release to check the production path: test access starts disabled and is enabled only by a verified StoreKit sandbox/Xcode app transaction.

## Limits

This isolates accelerated play and distinguishes file imports. It is not server-authoritative anti-cheat: local metadata can be edited by someone controlling the client. Game Center rankings are not implemented, and any future score publication needs its own eligibility and integrity checks. No score is submitted by this feature.

The previous time buttons modified the normal game without keeping an original copy. This change cannot reconstruct or reliably identify earlier accelerated progress; it preserves the existing game rather than silently resetting it. Future accelerated progress is isolated from the moment a new test copy is created.

## Authenticated transfers

New file and iCloud imports must also pass the format-2 HMAC verifier described in [Backup integrity](BACKUP-INTEGRITY.md). The provenance marker describes progression history; successful file authentication does not establish server-verified gameplay. Legacy unsigned transfers are refused, while existing local games remain playable and can be exported again.
