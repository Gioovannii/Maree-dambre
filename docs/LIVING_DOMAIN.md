# Native living domain

The approved illustrated concept is now the resource map in the SwiftUI app. Its UI was removed with the built-in ImageGen editor; gameplay values and controls are native and use the current saved game, not the numbers painted in the concept.

Active asset: `MareesAmbre/Assets.xcassets/DomaineAmbreChemins.imageset/DomaineAmbreChemins.png`.
The original `DomaineAmbreVivant` asset is retained. The new background removes
the painted people so every visible resident can be rendered independently.

## Rendering

`CoastalDomainScene` draws the fixed art, with a 24 fps `TimelineView` and a Canvas overlay. A six-second loop resamples small horizontal bands of the sea through `CoastalSeaMask` and adds restrained foam glints. It needs no WebView, browser, external runtime, custom Metal toolchain, or video decoder.

`VillagePedestrians(mode:)` draws seven independent residents in the resource
domain, using five routes registered to the dirt paths and bridge in the
887 × 1774 background. They walk at a constant screen-relative speed, pause at
each endpoint, and walk back with alternating limbs. They never use the old
town routes in the fields and do not traverse planted plots. The former
in-place worker-patch rotation has been removed. The centre retains its eight
residents and paved routes.

The overlays are decorative and do not intercept input or VoiceOver. Reduce
Motion removes moving water and holds pedestrians still. Timelines pause when
the app is inactive and in normal screenshot mode. Native resource counters,
selection, upgrade timers, navigation and plot details stay outside the
animation. Opaque panels prevent moving water from changing their backgrounds.

All ten original plot IDs and resource types are retained. Only their screen anchors changed in `SettlementLayout.swift`. Resource levels, production, upgrade costs and persistence rules are unchanged. The native level signs are placed over fixed resource art at every level.

## Verification

- Xcode simulator build, iPhone and iPad screenshot inspection, layout spacing checks, packaged French/English catalog checks.
- Motion comparison uses `--ui-snapshot --snapshot-motion-phase=0` versus `--ui-snapshot --snapshot-motion-phase=0.75`. The phase is clamped to 0–6 seconds; it cannot affect saved state.
- `--ui-snapshot --snapshot-animate` keeps the isolated demo fixture and enables live animation for viewing the actual app.
- Pedestrian positions can be compared with `--snapshot-motion-phase=0` and
  `--snapshot-motion-phase=6`. Pedestrians accept a bounded 0–360-second phase;
  water keeps its existing 0–6-second loop. Production builds animate without
  any launch argument. Installing a new TestFlight build is necessary to see
  this correction; editing the repository does not update an installed build.
- Opening a quarry, starting an upgrade, checking the resource deduction and countdown, and returning to the map were exercised in the isolated simulator fixture.
- Real-device frame time, energy use, and long-session thermal behavior still need device profiling before release.

16 October correction: Debug and optimized Release simulator builds pass. The
Release app was captured twice, six seconds apart with live animation enabled;
pedestrians visibly advance along paths and the bridge. Fixed phase 0/6 captures
differ by 0.3162% of pixels. Settlement layout checks pass. The existing resource
snapshot reference intentionally differs after replacing the background and the
earlier four-tab navigation change; the historical snapshot suite has not been
re-recorded as part of this correction. No TestFlight upload was performed.

## Image edit prompt

Latest edit, built-in ImageGen; saved in `DomaineAmbreChemins.imageset`:

Remove every small human character from the existing background and reconstruct
the crops, ground, timber or stone behind them. Preserve the donkey and cart,
exact portrait framing, coastline, roads, bridge, ten resource plots, fences,
trees, buildings, boats, warm colours, light and painterly sharpness. Only
remove people; add no objects, people, text or UI. The full generation prompt
also explicitly identifies workers in the lumber groves, crop plots, quarries,
cart area and bridge to prevent static figures being left behind.

Original UI-removal edit:

Precise production edit of this exact game screenshot: REMOVE ALL USER INTERFACE and reconstruct the artwork beneath it. Remove top resource bar and icons/numbers, title and decorative lines, all ten floating level circles and their numbers, selected gold circle, harbor button, bottom navigation panel, all text. Repaint those small areas seamlessly with ocean/terrain matching surroundings. Preserve EVERYTHING ELSE at EXACT pixel-relative positions: identical framing, 1:2 portrait aspect, ten productive areas (3 timber groves, 5 farms, 2 amber quarries), every farmer and miner and their poses and positions, trees, buildings, cart, bridge, coastline, sea, boats, paths, sunlight, colors, sharpness and perspective. Do not redesign, add, move or remove any world object. This will be a static game background with native interactive UI added separately; absolutely no text/numbers/UI left in the result, and exact source framing is essential for animated overlay registration. Output same portrait composition only.
