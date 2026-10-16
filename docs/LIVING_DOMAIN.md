# Native living domain

The approved illustrated concept is now the resource map in the SwiftUI app. Its UI was removed with the built-in ImageGen editor; gameplay values and controls are native and use the current saved game, not the numbers painted in the concept.

Asset: `MareesAmbre/Assets.xcassets/DomaineAmbreVivant.imageset/DomaineAmbreVivant.png`.

## Rendering

`CoastalDomainScene` draws the fixed art, with a 24 fps `TimelineView` and a Canvas overlay. A six-second loop resamples small horizontal bands of the sea through `CoastalSeaMask`, adds restrained foam glints, and pivots five local worker patches around their feet. It needs no WebView, browser, external runtime, custom Metal toolchain, or video decoder. Worker motion is a small working gesture; there are no walking characters or skeletal animations.

The overlay is decorative and does not intercept input or VoiceOver. Reduce Motion removes it completely. The timeline pauses when the app is inactive and in normal screenshot mode. Native resource counters, selection, upgrade timers, navigation and plot details stay outside the animation. Opaque panels prevent moving water from changing their background colors.

All ten original plot IDs and resource types are retained. Only their screen anchors changed in `SettlementLayout.swift`. Resource levels, production, upgrade costs and persistence rules are unchanged. The native level signs are placed over fixed resource art at every level.

## Verification

- Xcode simulator build, iPhone and iPad screenshot inspection, layout spacing checks, packaged French/English catalog checks.
- Motion comparison uses `--ui-snapshot --snapshot-motion-phase=0` versus `--ui-snapshot --snapshot-motion-phase=0.75`. The phase is clamped to 0–6 seconds; it cannot affect saved state.
- `--ui-snapshot --snapshot-animate` keeps the isolated demo fixture and enables live animation for viewing the actual app.
- Opening a quarry, starting an upgrade, checking the resource deduction and countdown, and returning to the map were exercised in the isolated simulator fixture.
- Real-device frame time, energy use, and long-session thermal behavior still need device profiling before release.

## Image edit prompt

Precise production edit of this exact game screenshot: REMOVE ALL USER INTERFACE and reconstruct the artwork beneath it. Remove top resource bar and icons/numbers, title and decorative lines, all ten floating level circles and their numbers, selected gold circle, harbor button, bottom navigation panel, all text. Repaint those small areas seamlessly with ocean/terrain matching surroundings. Preserve EVERYTHING ELSE at EXACT pixel-relative positions: identical framing, 1:2 portrait aspect, ten productive areas (3 timber groves, 5 farms, 2 amber quarries), every farmer and miner and their poses and positions, trees, buildings, cart, bridge, coastline, sea, boats, paths, sunlight, colors, sharpness and perspective. Do not redesign, add, move or remove any world object. This will be a static game background with native interactive UI added separately; absolutely no text/numbers/UI left in the result, and exact source framing is essential for animated overlay registration. Output same portrait composition only.
