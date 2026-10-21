# Neighbor garrisons and reconnaissance

Neighbor defense now sums actual unit defense values and a fortification bonus.
Each faction has its own two-unit composition, scaled in steps by level. This is
a deterministic simulated garrison, not a persistent army with recruitment and
enemy casualty depletion. Existing target cooldowns still apply after raids.

New raid orders freeze the enemy units and fortifications at departure; reports
preserve that snapshot. Old orders and reports without composition remain valid.

Observation is immediate, without deploying troops. Normal mode requires Academy
1 and reveals the total troop count. Advanced mode requires Academy 3 and reveals
counts by type, base per-unit attack/defense and fortifications. Human and reef
observations cost 20 food normally and 40 advanced; elves pay half.

Reports are saved per village and target. They become stale after ten minutes or
when the target's level changes. Upgrading a recent normal report to advanced pays
the full advanced price. A recent advanced report prevents redundant normal or
advanced purchases. No food is consumed on an invalid target, locked mode or
insufficient stock. Intelligence does not itself freeze the enemy for a future
raid; departure still snapshots the current garrison.

The world still shows aggregate defense and raid previews; observation provides
composition detail rather than gating existing preparation functionality.
