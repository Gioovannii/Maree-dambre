# Hero equipment

Equipment is shared across settlements and stored with the captain's personal mission state. It unlocks only after repairing the boat, so the five starting maritime supplies cannot be spent before the boat quest is complete. Upgrades are instantaneous, consume only maritime supplies, and are allowed only while the captain is not on a personal mission.

| Item | Level 1 / 2 / 3 cost | Effect at level 1 / 2 / 3 |
| --- | --- | --- |
| Spyglass | 4 / 9 / 16 supplies | Personal mission XP +10 / 20 / 30 percent |
| Sailor outfit | 5 / 11 / 18 supplies | +1 / 2 / 3 supplies per personal mission |
| Reinforced sail | 6 / 13 / 22 supplies | Total duration reduction 30 / 35 / 40 percent |

Equipment levels 1, 2 and 3 require captain levels 2, 4 and 6 respectively. The boat alone reduces personal mission durations by 25 percent. Sail upgrades add five percentage points each; the total reduction is capped at 40 percent. XP is rounded down to whole points. Only repeatable personal missions benefit; chapter quests, command XP from battles, armies, shipments and founding voyages are unaffected.

Each departure stores its equipment snapshot in the voyage. Completion and the saved report use that snapshot. Legacy voyages and reports without one retain their original timings and rewards. XP and inventory retain their existing caps. Costs, tier requirements, state and timestamps are validated before mutation; failed actions spend nothing. Existing saves default to no equipment.

Domain tests cover costs, captain-level gates, the protected boat quest supplies, tier caps, actual bonus rewards and durations, a voyage across settlement switching and reload, duplicate settlement prevention, legacy data, and unchanged army statistics and travel times.
