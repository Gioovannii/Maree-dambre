# Scheduled coastal assaults

Each exposed settlement receives one scheduled assault every 24 hours. This is initial balancing, independent of any future player-versus-player limits. New players receive their first assault 24 hours after beginner protection expires; extending protection also postpones this deadline. Existing saves without a deadline receive at least 24 hours of preparation when opened. Refuges receive no scheduled assaults.

The deadline is saved per settlement and displayed in the defense panel. All settlements are processed, including inactive ones. Simulation is local: when the app resumes, production, construction and returning missions settle first, then at most one overdue assault per settlement is resolved against the resulting garrison and stocks. The next deadline starts 24 hours after that resolution. Missed days never accumulate a backlog of raids.

Scheduled assaults reuse the coastal campaign: they advance up to three strategic tides to resolve exactly one battle. Convoys due on those tides settle under the same battle-before-return ordering as manual tides. A manual battle also postpones the regular assault for 24 hours. Neighbor rotation and capped enemy scaling follow the existing campaign rules.

Defense uses troops at home, fortifications, weapon levels and settlement bonuses. Troops away cannot defend. Losses and bounded pillage follow existing defense rules; buildings and fields remain intact. The structured defense report is saved in Messages for the attacked settlement. This feature does not schedule operating-system background execution, notifications, or network battles.

Verification: `Scripts/check-domain.sh` covers deadlines, protection extension, inactive settlements, offline caps, refuges and serialization; `Scripts/check-session.sh` covers persisted deadlines and a 14-day absence without duplicate combat after relaunch. Capture the interface with `SNAPSHOT_SCREEN=botAttacks Scripts/check-ui-snapshots.sh record`.

Automatic attacks respect the player device’s local calendar: night protection is 22:00–08:00, followed by a preparation hour until 09:00. Deadlines falling outside 09:00–22:00 move forward to the next 09:00. An overdue attack cannot settle during those protected hours, even after a long absence. This applies to inactive settlements too. Local calendar calculations handle timezone and daylight-saving changes on refresh. Voluntarily advanced strategic tides remain player-triggered actions; automatic attacks never require the player to advance a tide.

A pure reminder planner selects one hour before the next domain assault, omits past/quiet-hour reminders and suppresses additional reminders on a local day that already had one. Notifications remain optional and do not execute combat in the background.
