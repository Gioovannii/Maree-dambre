# TestFlight beta — 1.0 (12)

## Scope

This is the first solo village-building loop: production, field and building
upgrades, research, recruitment, raids, coastal defense, and maritime contracts.
Neighbors are simulated locally. The game works offline and saves on the device.
Multiplayer, colonization, additional player villages, and the Wonder are planned.

Start with a small tester group to measure comprehension, waiting times, save
reliability, and whether the first session gives players a reason to return.

## What to test

Suggested text for TestFlight's **What to Test** field:

> Build and upgrade your coastal village, research and train your first troops,
> then launch an expedition from the world map. Try the coastal defense campaign
> and maritime contracts once they become available.
>
> Please check that your village, timers, troops, and resources return correctly
> after closing and reopening the app. Explore the Resources, Town, World, and
> Missions tabs. Look for hidden buttons, unclear actions, unreadable text, or
> animation problems, especially the town shortcut and the moving ocean.
>
> Tell us where you got stuck, how long the first expedition took to reach, and
> what made you want to continue or stop. Include your device, iOS version, build
> number, a screenshot, and the steps that caused any problem. Use TestFlight's
> feedback feature to send your report.
>
> This beta is single-player and stores progress on your device. The twelve
> neighboring settlements are simulated opponents. Multiplayer and colonization
> are planned.

## Release checks

- Run domain, session, world-map, and coastline checks.
- Build a signed Release archive for a generic iOS device.
- Check the packaged French and English localizations.
- Run `Scripts/check-archive.py` against the archive to verify bundle metadata,
  app/widget version alignment, extension embedding, and privacy declarations.
- Validate and upload through App Store Connect; confirm processing succeeds.
- Assign the processed build to the intended TestFlight group. External testing
  may require beta review and completed beta app/review information.
- On a physical iPhone, play from a fresh installation through the first raid.
  Close and reopen during construction, research, recruitment, and the raid.
- Verify offline completion, a single return of loot and troops, construction
  Live Activities while suspended, the town shortcut, and ocean animation.
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
