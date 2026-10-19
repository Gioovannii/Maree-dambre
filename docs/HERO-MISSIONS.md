# Personal hero missions

One personal voyage may run at a time across the player domain. It stays with the shared captain when switching villages. Costs are paid by the selected village at departure; the completion report is delivered to that origin village. Missions settle on the domain clock, including offline returns, once only. Missed time does not auto-start additional missions.

| Mission | Duration | XP | Maritime supplies | Cost |
| --- | --- | --- | --- | --- |
| Discover the forgotten hull | 10 min | 30 | 2 | Free |
| Bring the boat home | 20 min | 50 | 3 | Free |
| Repair the boat | 30 min | 75 | 0 | 5 supplies, 200 wood, 80 amber, 100 food |
| Chart the coves | 15 min with boat | 20 | 1 | Free |
| Rescue a crew | 33 min 45 sec with boat | 40 | 2 | Free |

The table describes rewards and durations before crafted equipment bonuses. The Equipment tab can improve repeatable mission rewards and bring total duration reduction up to 40 percent; see HERO-EQUIPMENT.md.

The first three steps must be completed in order, once each. Repair unlocks a personal boat. Both repeatable missions require it, and their 20/45-minute base durations are reduced by 25 percent. Army, shipment and founding travel times are unaffected. Rewards are guaranteed and announced before departure. There are no random losses, paid skips or cancellation refunds.

Maritime supplies belong to the captain and are capped at 999. XP retains the existing level-20 cap; reports store the actual credited amount after caps. Hero mission XP is granted directly once during settlement and is not granted again by the generic command-XP mail processor. The hero identity, mission, inventory and report persist across relaunch. Old captains default to chapter zero without an active voyage.

Validation rejects invalid chapters, timings, origins, materials or missions not unlocked by the current chapter. Tests cover atomic repair payments, overlapping launch rejection, all chapter transitions, switching villages in transit, offline repair, faster repeatables, report origin, persistence and duplicate prevention.

The hero sheet places its compact portrait and XP above the personal mission panel. It shows the current chapter, resource cost, guaranteed rewards, a live countdown for an active voyage and the last report. The same report is available in Messages. iPhone snapshot cases: `heroMission`, `heroActive`, `heroRepair`, `heroBoat`.
