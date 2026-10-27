# Les Marées d’Ambre

A native iOS strategy and village-building game set in a sunlit coastal archipelago. Build your village, grow its economy, train troops, and prepare expeditions from a living, illustrated domain.

The current version is a **playable, offline, single-player beta**. Neighbors are simulated locally. Colonization, internal supply shipments and the five-stage Grand Lighthouse campaign objective are playable locally. Shared multiplayer and leaderboards remain planned.

## Run the project

Open `MareesAmbre.xcodeproj` in Xcode and select the **MareesAmbre** scheme. The app includes a WidgetKit extension for construction Live Activities. French and English are supported.

The current release configuration is **1.0 (build 21)** for both the app and the widget. Select your development team to run on a physical device or create a signed archive.

## Playable loop

1. Upgrade resource fields and grow your reserves. The resource bar shows current stock and storage capacity.
2. Develop the town center and warehouse. Reaching level 10 in a field unlocks its associated production building.
3. Build the House of Knowledge, research a unit, and build the training yard to recruit it.
4. Select a neighboring settlement on the world map, choose the troops to send, and launch a raid. Review the returning loot, survivors, and losses.
5. Prepare the coastal defense campaign and use maritime contracts to trade with an escorted convoy.

Production, construction, research, training, and raids are saved locally and catch up when the app resumes. The first raid returns after two minutes; distant expeditions take longer. The optional coastal defense and maritime contracts use player-advanced campaign tides. Separately, automatic enemy raids use spaced, randomized schedules and respect beginner and nighttime protection.

## Features

- **Field and building progression:** ten upgrade levels with increasing costs and construction times. The previous level remains active until completion. Fields and town buildings share one construction slot; cancellation refunds 50% of the paid cost, rounded down per resource. Construction also finishes while the app is closed.
- **Living domain:** ten painted resource plots with interactive levels and construction markers. Animated water and pedestrians follow the roads and bridge. Animations pause when the app is inactive and respect Reduce Motion. Stocks, selections, and upgrades use native SwiftUI controls. See [Living domain](docs/LIVING_DOMAIN.md).
- **Town center:** limestone architecture, shared visual styling, animated water, and pedestrians. Buildings can be moved between the twelve town plots, with one instance of each building. See [Town center design](docs/CENTER_HARMONIZATION.md).
- **Clear navigation:** separate Resources, Town, World, and Missions tabs. On compact screens, the Resources shortcut to the town sits above the bottom navigation bar.
- **Production and storage:** wood, amber, and food accumulate up to the shared storage limit: 300 initially, then 300 + 500 per warehouse level. Fractional production and the last production timestamp are preserved.
- **Army:** two units per clan, research, recruitment, and selective troop deployment. Troops left behind defend the village. Expedition preparation shows estimated strength, losses, and the remaining garrison; a mage only affects an expedition when sent with it.
- **Twelve upgradable buildings:** each level improves its effect. The forge researches ten weapon levels separately for each unit type, limited by the forge level. Each weapon level adds one attack and defense point. Expedition bonuses are fixed at departure; weapon research also completes offline. See [Progression](docs/PROGRESSION.md) and [Building rules](docs/BATIMENTS.md).
- **World map:** a fictional 200 × 200 tile archipelago with illustrated terrain, twelve simulated neighbors across three tribes, and clan details in settlement panels. Neighbors range from nearby to 90 tiles away, with raid strength and return time scaling by distance. Their territories grow every six hours. Map movement and zoom are local. See [World map design](docs/WORLD_HARMONIZATION.md).
- **Coastal defense:** opt in after building the training yard and recruiting a unit. The nearest neighbor leads the first attack after two campaign tides; tribes then take turns, with later waves growing stronger. The watchtower adds 20 defense per level. The player decides when each tide advances.
- **Maritime contracts:** accessible through the market or world screen. Send wood and food along a safe or exposed route, choose an escort, and collect amber. Survivors return after combat; unclaimed payments remain available when storage is full.
- **Grand Lighthouse:** after founding three villages, fund five construction stages from the capital, using colony supply shipments as needed. Work finishes offline; each new stage requires a separate payment. Lighting the beacon records campaign victory and ends automatic raids while keeping the domain playable. See [Lighthouse rules and costs](docs/MERVEILLE.md).
- **Persistent village:** the initial world seed depends on the UTC week, but an existing village survives week changes. Save validation protects unreadable data and migrates older saves.
- **Construction Live Activities:** remaining construction time appears on the Lock Screen and Dynamic Island.

## Verification

Run the domain and session checks from the repository root:

```sh
sh Scripts/check-domain.sh
sh Scripts/check-campaign.sh
sh Scripts/check-session.sh
sh Scripts/check-worldmap.sh
sh Scripts/check-coastline.sh
```

These cover resources, construction, progression, save migration and validation, recruitment, troop selection, raids, losses, loot, defense, commerce, world generation, and offline recovery. The campaign check follows all three peoples from a fresh village through a first raid, a second village, an army above 100 troops, and advanced buildings and weapons, paying every cost from actual production. See [Campaign progression audit](docs/CAMPAIGN-AUDIT.md) for its scope and measured timings. Session checks use isolated preferences and do not modify an existing game.

Save validation rejects out-of-range dates, invalid production fractions, and construction jobs that overwrite a building or use an invalid plot. An unreadable save stays intact until the player explicitly starts a new village. That action preserves a diagnostic copy under `village.unreadable.<seed>.<identifier>`; restoring that copy is not yet available in the app.

Check packaged French and English translations after building:

```sh
sh Scripts/check-localization.sh /absolute/path/to/MareesAmbre.app
```

### Visual checks

On iPad, windows at least 700 × 600 points show the map and details side by side. Smaller windows use the compact layout. Check Resources, Town, research, recruitment, and World in portrait, landscape, and a reduced window before distributing an iPad build.

At accessibility text sizes, resources stack vertically and the main screens scroll. Plots are presented as a list with full names, while selection and building movement retain the same actions. Check the largest text size and VoiceOver, then restore the simulator settings before comparing screenshots.

The screenshot scripts discover Xcode and the matching iOS 27.0 simulator, fix the app language to French, and freeze the status bar. Override `DEVELOPER_DIR` or `SIMULATOR_ID` to select a specific installation or device.

```sh
# Nine iPhone references: resources, town, upgrade, world, market,
# forge, infirmary, quay, and maritime contracts.
zsh Scripts/check-ui-snapshots.sh verify

# Three iPad references.
SNAPSHOT_DEVICE=ipad zsh Scripts/check-ui-snapshots.sh verify
```

Use `record` instead of `verify` only after visually reviewing an intentional change. Not all references are necessarily current after a UI change; inspect differences before updating them.

Launch arguments provide isolated demo scenarios:

| Arguments | Scenario |
| --- | --- |
| `--ui-snapshot` | Deterministic demo village with frozen animations |
| `--ui-snapshot --snapshot-world` | World map |
| `--ui-snapshot --snapshot-world --snapshot-animate` | World map with live water animation |
| `--ui-snapshot --snapshot-center --snapshot-construction` | Town construction |
| `--ui-snapshot --snapshot-new-village` | Village founding without changing real saves |
| `--ui-snapshot --snapshot-save-recovery` | Unreadable-save warning |
| `--ui-snapshot --snapshot-center --snapshot-developed` | All twelve town buildings |
| `--ui-snapshot --snapshot-market` | Market panel |
| `--ui-snapshot --snapshot-forge` | Forge panel |
| `--ui-snapshot --snapshot-infirmary` | Infirmary panel |
| `--ui-snapshot --snapshot-expeditionQuay` | Expedition quay panel |

Add `--snapshot-actions` to frame a panel's lower actions. Demo arguments are for development and do not represent normal launch behavior.

## TestFlight beta

Development and verified TestFlight builds offer an isolated **Test copy** under Settings → Backup. Time controls affect only that local copy; restarting the app returns to normal play. Test copies cannot be exported or uploaded to iCloud. File imports retain their provenance. New backups use HMAC-authenticated payloads and a synchronizable Keychain key; unsigned or modified files are rejected. See [Backup integrity and migration](docs/BACKUP-INTEGRITY.md) before transferring an older backup. See [Isolated test games](docs/TEST-MODE.md).

This build is intended to test the first solo loop, visual clarity, waiting times, and balance with a small initial tester group. It does not require an online game server.

Before wider distribution, play from a fresh installation through the first raid on a physical iPhone. Close and reopen the app during construction, research, training, and an expedition. Verify the return of troops and resources, construction Live Activities while the app is suspended, the town shortcut, and water motion. Repeat the important navigation paths on iPad and at the largest text size. Longer sessions are still needed to assess high-level progression and storage growth.

Create a Release archive for a generic iOS device, then check its packaged metadata:

```sh
python3 Scripts/check-archive.py /absolute/path/to/MareesAmbre.xcarchive
```

The privacy manifest declares app-only `UserDefaults` access for local saves (Apple reason `CA92.1`), with no tracking or data collection. The local archive check verifies bundle metadata, matching app/widget versions, extension embedding, and the manifest. Apple's signed distribution validation is also required.

Use Xcode Organizer to validate and upload the archive to App Store Connect. Once Apple finishes processing it, select the build for the intended TestFlight group. Uploading an archive alone does not make it available to testers; external testing may require beta review.

See [Beta testing notes](docs/TESTFLIGHT.md) for the test scope and tester instructions.

## Current limits and direction

Twelve neighboring settlements across three tribes are simulated opponents. Raids and defense resolve locally, without animated travel to the target or manual combat control. There are no player accounts, shared multiplayer, alliances or leaderboards yet. A capital and two colonies, internal supplies and authenticated backup transfer are available. Physical-device cross-device recovery still needs verification. Balance is provisional.

The current campaign ends by reconstructing the **Grand Lighthouse across five stages**, with three owned villages. A final siege and shared competition remain future design work. See [Lighthouse design](docs/MERVEILLE.md).

The opening currently leads from the prologue and clan choice directly to the village. Contextual onboarding accompanies early village development. A fresh-player test should establish whether the next objective is clear without guidance.

Most detailed design documents are currently written in French.
