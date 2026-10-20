# TestFlight beta — 1.0 (16)

## Scope

This is a broader solo strategy beta: village development, research, recruitment,
raids, coastal defense, hero missions, equipment, settlement expansion, supply
shipments, a mailbox, and scheduled attacks. Neighbors are simulated locally.
The game works offline and saves on the device. Shared multiplayer and the Wonder
are planned.

Start with a small tester group to measure comprehension, waiting times, save
reliability, and whether the first session gives players a reason to return.

## What to test

Suggested text for TestFlight's **What to Test** field:

> Develop your village, train and upgrade troops, and raid nearby and distant
> simulated neighbors. Try the hero missions, found a second settlement, and
> send supplies between your villages. Check the mailbox for battle reports and
> test the coastal defense campaign.
>
> Please check that your villages, timers, troops, and resources return correctly
> after closing and reopening the app. Test overnight protection, hero missions
> and equipment, supply delivery, battle previews and reports, and village
> switching. Explore the Resources, Town, World, and Missions tabs on iPhone and
> iPad. Report unclear actions, balance problems, unreadable text, or animation
> issues.
>
> Tell us where you got stuck, how long the first expedition took to reach, and
> what made you want to continue or stop. Include your device, iOS version, build
> number, a screenshot, and the steps that caused any problem. Use TestFlight's
> feedback feature to send your report.
>
> This beta is single-player and stores progress on your device. The twelve
> neighboring settlements are simulated opponents; there is no shared world or
> player-versus-player combat yet.

## Release checks

- Run domain, session, world-map, and coastline checks.
- Build a signed Release archive for a generic iOS device.
- Check the packaged French and English localizations.
- Run `Scripts/check-archive.py` against the archive to verify bundle metadata,
  app/widget version alignment, extension embedding, and privacy declarations.
- Validate and upload through App Store Connect; confirm processing succeeds.
- Assign the processed build to the intended TestFlight group. External testing
  may require beta review and completed beta app/review information.
- On a physical iPhone, play from a fresh installation through the first raid,
  hero mission, and second settlement.
- Close and reopen during construction, research, recruitment, a raid, a hero
  voyage, and a shipment. Confirm each reward and delivery is applied once.
- Verify overnight protection and scheduled attack timing, battle previews and
  reports, storage forecasts, return summaries, and village switching.
- Verify construction Live Activities while suspended and the town shortcut.
- Check essential navigation on iPad, with VoiceOver, and at the largest text size.

Automated checks cover the first raid path and save recovery. They do not replace
physical-device testing or several days of progression and balance feedback.

## Build 11 changes

- Visible ocean swell with an illustrated water texture on the world map.
- Refined coastlines without the broad turquoise glow.
- Resources-to-town shortcut positioned above the bottom tabs on compact screens.
- App and widget aligned at version 1.0, build 11.
- English repository README and beta testing instructions.

Build 9 also introduced ten-level building progression, increasing costs and
timers, separate weapon upgrades per unit type, and the harmonized archipelago.

## Build 12 changes

- Expanded the world from three to twelve simulated neighbors, including targets up to 90 tiles away.
- Raid duration and enemy strength scale with target distance and level.
- Defense campaigns now name the attacking neighbor and rotate among the tribes.
- Raid reports show attack strength, defense strength, losses, and the loot actually stored.
- App and widget aligned at version 1.0, build 12.

Build 11 was already present in App Store Connect, so this release uses build 12.

## Build 16 changes

- Added guided objectives and a configurable hero with persistent experience,
  levels, repeatable missions, boat travel, and equipment upgrades.
- Added persistent settlements, internal resource shipments, a unified mailbox,
  and scheduled coastal defenses.
- Added overnight attack protection, quiet raid reminders, storage forecasts,
  and optional summaries for activity completed while away.
- Refined faction identities, unit profiles, raid casualty estimates, and the
  battle preview. Decisive victories no longer apply a fixed casualty tax,
  including for raids already underway when the rules changed.
- Adapted iPhone to portrait and redesigned iPad layouts for both orientations,
  with warm Liquid Glass tab bars.
- App and widget aligned at version 1.0, build 16.
