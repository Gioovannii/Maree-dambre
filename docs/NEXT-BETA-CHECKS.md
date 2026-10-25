# Next beta device checks

The current checkout is version 1.0, build 21. These changes are committed on main; this document does not indicate that an archive was uploaded to TestFlight.

## Physical transfer verification

Use two signed devices running the updated app and the same Apple Account. Keep the original game on the source device until all checks pass.

1. Enable iCloud Keychain synchronization on both devices. Export a fresh protected backup from the source. Import it on the receiving device. Review the people, village count, building and field levels before confirming. Confirm that the restored game matches the source snapshot and can resume play.
2. Upload a fresh snapshot from the source through the in-game iCloud backup controls. Refresh on the receiver, review and restore. Confirm that this path also authenticates the payload.
3. Modify an exported payload without its authentication key. Both preview and restoration must fail, preserving the receiving device’s game. An older unsigned export must also be refused with guidance to export again.
4. On a receiving device where the export’s key has never synchronized, verify that import fails safely. Merely disabling synchronization after the key has arrived does not remove the locally cached key and is not a missing-key test.
5. Enter an isolated test copy. Verify that export, upload and normal restoration are disabled. Return to normal play and confirm the original game is intact.

A missing key must never be replaced with an unprotected import. Restore is manual; games are not merged. Authentication is not server validation of gameplay or rollback prevention.

## UI and progression checks

- On iPad, open Missions in portrait and landscape. Keep the village header at the top and one scrolling mission page. Confirm that map screens still retain their adaptive map/inspector layout.
- With two villages, follow the domain objective. Its button must select the appropriate village and open the indicated field or building. At the colonization step, it opens the founding sheet from the capital.
- Check the defensive people’s recommendation badge at new-game selection, and the tactical advice disclosure in Missions.
- Check a scheduled incoming raid: its target remains fixed through village switching, reloading and night postponement. After resolution, exactly one matching report appears.

## Simulator evidence

Release compilation and packaged French/English localization checks are recorded during development. iPad portrait captures cover the domain journey and backup comparison. Domain/session simulations exercise authenticated transfers with isolated injected keys, not the physical Keychain synchronization service.
