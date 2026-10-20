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

Cloud synchronization, conflict selection, and recovery of a save from an erased
device remain separate work. Signing into the same Apple account does not currently
download progress. The backup must be exported from an installation that still
contains the desired game.
