# Campaign progression audit — 24 October 2026

## Reproduce

Run `sh Scripts/check-campaign.sh`. The script compiles the real domain model and storage implementation, runs in UTC, and uses isolated preferences. It does not modify a player's save or submit scores.

The simulation starts from the normal 80 wood, 35 amber and 60 food. All later resources come from production and the first raid. No resource, level, troop or unlock is injected. Waiting advances the simulation clock by one minute; constructions and voyages complete at their real deadlines. The same route is played for each people.

The route activates one field of each type, builds the academy and training grounds, researches and recruits two basic soldiers, and completes a nearby raid. It then grows all ten fields to level 4, develops the expansion prerequisites, researches navigation, prepares settlers, and founds a production village in a refuge. It visits and develops that village, returns to the capital, grows its army above 100, develops one field of each type to level 10, builds the advanced production buildings, and researches one unit's weapons through level 10. Automatic enemy attacks remain enabled after beginner protection expires. Saves are validated and reloaded at the milestones, including while settlers are sailing.

## Results

| Milestone, elapsed simulated time | Humans | Reef folk | Marsh elves |
| --- | ---: | ---: | ---: |
| First raid returns | 15 min | 52 min | 10 min |
| Second village founded | 73.49 h | 77.86 h | 71.80 h |
| Army above 100 | 90.40 h | 94.57 h | 87.50 h |
| Advanced buildings and level-10 weapons | 188.28 h | 198.04 h | 184.46 h |
| Longest uninterrupted resource wait | 29.80 h | 29.25 h | 23.18 h |

These are measurements of a scripted route, not predictions of player retention or typical completion times. The script does not repeatedly farm neighbors, trade, use hero rewards, extend protection, or optimize every investment. It also cannot validate whether the interface makes each action discoverable.

## Correction made

The opening guide previously counted any developed field as sufficient preparation for recruitment. A player could develop only wood, then research troops requiring amber while producing only one amber per hour. A baseline route recruiting four reef soldiers took about seven hours to return from its first raid.

The guide now asks for at least one level-1 field of each resource and points to the next missing type. A regression check verifies that every people can complete a guided opening with two basic soldiers within an hour. The four-soldier baseline and two-soldier guided route are different scenarios, so their timings must not be presented as a like-for-like balance comparison. Troop prices, production rates and starting resources have not changed. Previously recorded tutorial progress and legacy battle reports remain recognized.

## Remaining observations

- The first colony requires approximately a day of uninterrupted saving in this route. This supports a deliberate expansion milestone, but the game should explain this goal and keep raids, hero missions and economic improvements useful during preparation.
- Researching the most expensive weapons before investing in production produced waits of roughly 33–37 hours in an earlier route. Investing in production first reduced the full route from roughly 10–11 days to roughly 8 days. This is a strategic trade-off, not a storage deadlock.
- Resolved after the audit: new towns have twelve visible lots, including a new lower-left lot and the quay. The campaign route now selects only visible lots. Legacy lot 22 accepts existing saved buildings and paid construction, but no new placement or move destination. Existing occupants can still be upgraded or moved out.
- The audit does not cover a third village, conquest, a Wonder, shared rankings, tamper resistance, or cross-device conflict resolution. Domain checks separately cover third-village costs, maximum warehouse capacity and level-10 upgrade affordability.
- A device playtest is still needed for the tutorial, recruitment, colonization and switching villages on iPhone and iPad.
