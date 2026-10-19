# Initial protection

Implemented on 19 October 2026.

- Protection starts when a new player chooses a people and lasts 72 hours.
- The player can activate one 48-hour extension while the initial protection is still active. It is added to the original deadline, giving 120 hours in total, and cannot be purchased or repeated.
- Protection belongs to the whole domain. Switching or founding villages does not create a new deadline or another extension.
- Existing saves upgraded from versions before 19 receive a single 72-hour grace period on migration. Subsequent launches preserve the deadline.
- The Missions screen and defense modal show the remaining time, deadline and extension command.
- Protection start, extension and expiry produce saved mailbox notices. Expiry is recorded once even after a long absence.
- Player-initiated raids and supply routes remain available. Maritime contracts retain their own advertised route risks.
- The current coastal campaign is still advanced manually. During protection, an incoming village assault is postponed without losses or stolen stock; strategic tides and commercial convoys continue. Postponed tides are stored so the campaign remains valid after relaunch.
- Refuge protection is independent and remains effective after initial protection expires.

Regular automatic enemy attacks and changing the capital are not implemented by this feature. No automatic-assault cadence or absence rule is silently selected here. The existing manual campaign remains explicit about this in its interface.

Save version 19 validates protection dates, stores the domain-wide protection only on the selected root village, and preserves that value while switching. Tests cover exact expiry boundaries, the one-time additive extension, continued commerce, assault suppression, expiry notices and migration without timer resets.
