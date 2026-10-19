# Player captain

The first hero feature uses two original illustrated 2D portraits and a native character sheet. Open it from the persistent portrait button beside the main header on all five tabs, or from the first card in Missions. This entry also works when an existing save has no hero yet. Players can choose a female or male captain and a name of 1–24 characters. Portrait and name can be edited for free; both choices have the same gameplay possibilities.

`PlayerHero` is optional for compatibility with existing saves and belongs to the player domain. When switching settlements, it transfers to the selected root and is removed from inactive snapshots. Storage rejects invalid names and duplicated hero state in inactive villages. No automatic creation or changes to old names occur during migration.

Implemented: selection, Unicode name validation, editing, portrait assets, global identity, persistence, French and English UI, VoiceOver selection traits and iPhone snapshot fixtures (`hero`, `heroProfile`). The guide remains a separate onboarding feature.

Experience and levels are now implemented as domain-wide command progression. A battle victory grants 20 XP and a defeat 5 XP. Only the first raid result per neighbor per UTC day is rewarded, shared across villages; only the first defense per village per UTC day is rewarded. Founding a colony grants 75 XP. No XP is granted for reports before progression starts or imported legacy reports. Editing a name or portrait preserves all progress.

Level 1 starts at 0 XP. The first level costs 100 XP, and each following level costs 50 XP more than the preceding one. Level 20 is capped at 10,450 total XP; excess XP is discarded. The sheet displays level, within-level progress and total experience, while the Missions card displays level and XP. Positive grants are visible in their mail report.

Rewards settle once from persisted structured mail events after domain updates, including inactive villages and offline returns. A saved per-mail XP marker prevents repeat grants after reloading or reading reports. A bounded daily key set prevents duplicate daily rewards even if a report is pruned. Progression is initialized for legacy portraits without retroactive credit.

Not implemented yet: physical expedition/defense assignment, level-based combat bonuses and three equipment slots (weapon, outfit, navigation instrument). XP represents command experience across the domain, not simultaneous physical deployment in multiple armies. The sheet explains this and displays no inactive equipment controls.

The RealityKit maquette was removed after evaluating its scope. Full 3D characters and interchangeable armor are outside the current beta scope. Validate the gameplay before commissioning rigged characters.

Tests: domain hero checks and actual-session relaunch and village-switch checks run through `Scripts/check-domain.sh` and `Scripts/check-session.sh`. Capture the UI with `SNAPSHOT_SCREEN=hero,heroProfile Scripts/check-ui-snapshots.sh record`.

Portrait assets were generated for this project with the built-in image generation tool: original maritime captains in teal coats, amber jewelry and a painterly dusk palette. They use no third-party character model or existing franchise reference.
