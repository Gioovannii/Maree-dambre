# One clock for missions — 27 October 2026

The player no longer starts a separate coastal defense campaign or advances tides
manually. Incoming enemy raids keep their existing randomized 8–15-day scheduling,
beginner protection, nighttime protection and domain-wide targeting rules. The
Defense sheet now shows the announced attack, available garrison and latest report.
It does not preview an unrelated turn-based wave or offer an extra assault button.

Maritime contracts are independent of village attacks. The sheltered route takes
30 minutes; the exposed route takes 20 minutes. Each route becomes available again
one hour after departure. Cargo prices, rewards, escort capacity and encounter
losses are unchanged. One convoy per village and an outstanding amber payment still
block another departure. Escorts return automatically, including offline and while
another village is selected. Pending payment is kept until storage can hold it.
A voyage never requires a village assault to advance and a scheduled assault cannot
complete a timed voyage early.

Save schema 21 adds an optional departure timestamp to convoy orders and optional
route cooldown dates to commerce. Existing turn-based voyages migrate on load:
each remaining turn becomes ten minutes, preserving cargo and troops. This one-time
conversion starts from the migration time because older saves have no real departure
time. Existing completed reports and pending payments remain unchanged. Historical
turn fields and resolution helpers remain for old save validation and the internal
automatic-raid simulation; they are not player-facing controls.

Domain checks cover exact return time, no early completion through the old turn
helper, single escort return and payment, cooldown and old-save migration. Session
checks cover departure without a defense campaign, relaunch during travel, offline
return, full-storage payment escrow and subsequent collection. This is an initial
travel-time baseline, not a measured retention result.
